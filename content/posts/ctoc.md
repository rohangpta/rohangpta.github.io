---
title: "Reverse Engineering Claude's Token Counter"
description: "ctoc"
date: 2026-02-10
tags:
  - coding agents
draft: false
params:
  math: true
---

Claude 3+ doesn't ship with a public tokenizer.

If you're building coding agents, that's a practical problem. You either call Anthropic's `count_tokens` for everything (slow, online, awkward) or use a proxy estimator (`tiktoken`, `wc -c // {3,4}`) and accept large systematic error - up 20-50%  for Claude models.

`count_tokens` is a decent solution that facilitates context compaction, but we're increasingly entering a world where coding agents need to actively self-manage context and avoid triggering the high-variance/hacky compaction process.

We're already starting to see this with recent models' awareness of their own context and tendency to truncate commands with `head` / `tail`. And as we start parallelizing across the agent axis, I don't see `count_tokens` scaling well to support demand.

So I thought - wouldn't it be great if we could give the agent a simple, local tool to see the token usage of a whole directory? similar to how we humans do `cloc` to see file sizes, but just in the token world

```
➜  eval git:(main) cloc . --by-file                                                                                                                                    +
       6 text files.
       6 unique files.
      19 files ignored.

github.com/AlDanial/cloc v 2.08  T=0.01 s (493.3 files/s, 117415.2 lines/s)
--------------------------------------------------------------------------------
File                                         blank        comment           code
--------------------------------------------------------------------------------
./results/hhiksu22.json                          0              0            820
./runner.py                                     34             12            184
./postprocess.py                                31             10            108
./modal_eval.py                                 17              8             91
--------------------------------------------------------------------------------
SUM:                                           111             43           1274
--------------------------------------------------------------------------------

```

So over what ended up being a 3 day experiment I reverse-engineered a large chunk of Claude's vocabulary from the `count_tokens` API and built `ctoc`: `cloc`, but token-aware.

`ctoc` is a greedy offline estimator of Claude 4.x's `count_tokens()` API that lands at around 96% accuracy and is backed by a 36,495-token verified vocabulary. The code and vocabulary are [open source](https://github.com/rohangpta/ctoc/tree/main) and builds into a self-contained executable.

## A primer on BPE tokenization

Tokenizers these days mostly use the [BPE algorithm](https://en.wikipedia.org/wiki/Byte-pair_encoding). BPE is "trained" by using a fixed/private corpus of data to create a table of merge rules of frequent tokens.

Say the merge table (in priority order) is:

1. t + h → th
2. th + e → the
3. i + s → is

Tokenizing the input "this":

- Start:  [t, h, i, s]
- Rule 1: [th, i, s]       — merged t+h
- Rule 2: no "th"+"e" pair — skip
- Rule 3: [th, is]         — merged i+s
- Done:   ["th", "is"]

You scan through the rules in order, applying each one everywhere it matches,
until no more rules apply.

Now we're not *certain* that Anthropic uses BPE but given that... pretty much everyone in the industry seems to have converged on this, it's a reasonable bet.

This means that without this "merge table" or private corpus we can't *exactly* re-create the tokenization.

But - if we can identify the total vocabulary of this tokenizer, can we re-create a good enough esimator using another algorithm that approximates BPE?

## Probing count_tokens to identify vocabulary

The `count_tokens` API has an interesting property that makes all of this tractable:

> For a string s, position `i` is a token boundary in `s` iff `any(count(s[:i]),count(s[i:])) == 1`.

So, if we can single out tokens by splitting a string, we can identify a valid node in the BPE graph (you can view the merge rules as edges and tokens as nodes)

The core issues that we ran into here are:

- API counts are not just `len(tokenizer(text))`. They include some source of ~roughly constant size overhead, dependent on the starting token. Single-char probes starting with letters, digits, and some Unicode classes had different effective overheads (7,8,9+ respectively - what's going on here, Anthropic?). The fix here was sandwich counting: wrap every probe between marker tokens that we knew to be singular.

```python
def count_tokens(text: str) -> int:
    marker = "\u00A7"
    base = raw_count(marker + marker)
    return raw_count(marker + text + marker) - base
```

- Brute-force over all possible byte strings is exponential. The search space for tokens of length 1-64 over 256 byte values is astronomical. Furthermore, our probing strategy was linear in the size of the string. Early experiments with generated data or public datasets proved to be intractable very quickly, but we did find a few "definite" tokens, showing some signs of life in this approach.

### Cross-tokenizer mining 

I needed a way to narrow the search space to something that would run in days vs centuries.

After some back and forth with Claude, I arrived on cross-tokenizer mining: decode vocab items from existing BPE tokenizers (tiktoken, HuggingFace models), test each against Claude with sandwich counting, keep only single-token hits.

Tokenizers trained on overlapping internet/programming corpora converge on many of the same subwords. This isn't surprising if you think about it from a compression angle, and the Anthropic-specific tokens are likely not dominant in the distribution.

| Source | Vocab size | Hit rate | New tokens found |
|---|---|---|---|
| tiktoken cl100k_base (GPT-4) | 100K | ~46% | ~29,000 |
| tiktoken o200k_base (GPT-4o) | 200K | ~15% | ~4,000 |
| 11 HuggingFace US + China models | 150-250K each | 2-74% | ~3,800 |

Sorting multilingual candidates by cross-tokenizer frequency (tokens appearing in more tokenizers checked first) gave a 74% hit rate on the first 1,000 candidates, declining to ~2% by 20K.

### Long tail

NOTE TO SELF: this part seems more interesting - I should expand on it. whast does it really mean for these kinds of tokens to have special significance? is it an optimization for the codegen?

NOTE TO SELF 2: Yeah generally also need far more stuff in here to close it out smoothly; describ e the IMPL, close out with a nice conclusion

It's rumoured that certain tokenizers overemphasize code-tokens in their distributions - studying these tokenizers would be an experiment of its own.

Lower-yield but still meaningful. After fixing the baseline bug, re-checking all digit-starting candidates recovered ~1,006 tokens — almost all 3-digit numbers (`916`, `030`, `271`) are single tokens. BPE creates single tokens for specific lengths of repeated characters (`=`, `-`, etc.) up to length 64 with non-monotonic patterns: `"=" * 7` is 2 tokens but `"=" * 8` is 1. Space sequences 1-16, tab sequences 1-4, and newline variants are each single tokens — critical for code indentation accuracy.

## Results

### Estimator quality (greedy longest-match)

| Corpus | Efficiency (`API / greedy`) |
|---|---:|
| Python source | 96.1% |
| Mixed code + docs | 95.1% |
| English prose | 99.2% |

Greedy usually over-segments a bit (more tokens than API), which is acceptable for context budgeting.

### Conclusion - ctoc

The outcome of this project was `ctoc`.

`ctoc` is deliberately boring: embed the verified vocab into a C++ binary at build time, build a trie, greedy longest-match over file bytes, fallback unknown byte => 1 token, aggregate by extension or file. Fast enough to run as a preflight check in local workflows, or for a coding agent to run as a subprocess.

TL;DR: If you care about exact counts for billing-critical paths, use Anthropic's API. If you care about fast, parallelizable, local (self)context management, this could be good enough.

---

## Appendix 

## Why does greedy do well?

What turned out to be empirically true but not obvious - greedy longest-match and BPE merge-order produce *different segmentations*. Why do the token *counts* nearly converge?

There's a reasonable theoretical picture:

BPE vocabularies are built for greedy compression. Zouhar et al. (2023) formalise BPE training as greedy submodular maximisation of a compression utility. The vocabulary is constructed bottom-up: every multi-character token was formed by merging two shorter tokens that are also in the vocabulary. This hierarchical structure means the longest token at any position tends to be the one BPE would also select.

Byte-level completeness prevents dead ends. BPE vocabularies always include single-byte fallback tokens, so a left-to-right greedy pass can never paint itself into a corner. This eliminates the primary failure mode of greedy algorithms on arbitrary dictionaries.

BPE training also has an implicit left-to-right bias. Sawada & Goyal (2025) observe that BPE merge training processes strings left-to-right and breaks frequency ties in left-to-right order. They show empirically that greedy left-to-right encoding over a BPE vocabulary matches or *exceeds* standard merge-order BPE on downstream tasks.

And where greedy and BPE do disagree, the result is typically a rearrangement of boundaries, not a net increase in tokens. `['hell', 'ooo']` vs `['hello', 'oo']` — different boundaries, same count.

The upshot: when you have the complete vocabulary, greedy and merge-order counting converge regardless of the tokenisation algorithm. The 4-5% gap in `ctoc` is missing tokens forcing over-segmentation. If the vocabulary were complete, greedy counting would likely be 99%+ accurate.

