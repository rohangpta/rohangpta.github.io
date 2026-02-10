---
title: "Reverse Engineering Claude's Token Counter"
description: "How I reverse-engineered a large Claude vocabulary from count_tokens and built a fast local token estimator."
date: 2026-02-10
tags:
  - coding agents
  - nlp
draft: false
params:
  math: true
---

Claude 3+ doesn't ship with an open tokenizer.

If you're building coding agents, that's a practical problem. You either call Anthropic's [`count_tokens`](https://docs.anthropic.com/en/api/messages-count-tokens) for everything (slow, online, awkward) or use a proxy estimator (`tiktoken`, `wc -c // {3,4}`) and accept large systematic error - up to 20–50% for Claude models. As agents increasingly self-manage context, they need a fast, local way to see token usage across a directory — [`cloc`](https://github.com/AlDanial/cloc) (count lines of code), but for tokens.

So I reverse-engineered a large chunk of Claude's vocabulary from the `count_tokens` API and built [`ctoc`](https://github.com/rohangpta/ctoc/tree/main):


```
➜  ctoc git:(main) bazel-bin/ctoc --by-file .
--------------------------------------------------------------------------------
File                                Ext                tokens
--------------------------------------------------------------------------------
./MODULE.bazel.lock                 .lock              22,906
./ctoc.cc                           .cc                 4,870
./REPORT.md                         .md                 4,290
./gen_vocab.py                      .py                   962
./README.md                         .md                   473
./BUILD.bazel                       .bazel                246
./MODULE.bazel                      .bazel                153
./020020-huh-isk                    .dat                   22
--------------------------------------------------------------------------------
SUM (8 files)                                          33,922
--------------------------------------------------------------------------------
```

`ctoc` is an offline estimator of Claude 4.x's `count_tokens()` API that lands at ~96% accuracy. It's backed by a 36,495-token verified vocabulary (greedy tokenizer), and the code/vocabulary are [open source](https://github.com/rohangpta/ctoc/tree/main).

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

That's a toy intuition, not a full encoder spec: practical BPE implementations track merge priorities over adjacent pairs as well.

Now I'm not *certain* Anthropic uses BPE, but given that most of the industry has converged on it, it's a reasonable bet.

This means that without this "merge table" or private corpus we can't *exactly* re-create the tokenization.

But if we can recover the vocabulary, we don't need the merge table — a greedy longest-match over the known tokens should approximate BPE's token counts closely enough.

## Probing count_tokens to identify vocabulary

We need to do two things to reverse engineer Claude's vocabulary: verify whether a candidate string is a single token, and decompose longer strings to extract tokens we haven't seen yet.

### Single-token verification

The naive check — send a candidate to `count_tokens`, see if you get 1 — doesn't work because the API wraps inputs in chat framing. Raw counts include a roughly constant overhead that varies by the type of the first character (7, 8, 9+ for letters, digits, Unicode respectively - what's going on here, Anthropic?).

Sandwich counting fixes this: wrap every probe between markers that we know are single tokens, and subtract the known baseline.

```python
def count_tokens(text: str) -> int:
    marker = "\u00A7"
    base = raw_count(marker + marker)
    return raw_count(marker + text + marker) - base
```

With this, `count_tokens(candidate) == 1` reliably tells us whether a candidate is a single token.

### Decomposing strings into tokens

Verification handles candidates we already suspect are single tokens. But when we encounter a longer string - from a dataset, from another tokenizer's vocab - we need a way to extract the individual tokens inside it.

The approach: scan for a position `i` where `count(s[:i]) == 1` or `count(s[i:]) == 1`. That peels off one confirmed token from either end. Recurse on the remainder until the string is fully decomposed (or you hit a chunk that can't be broken down further).

So we have the machinery: sandwich counting to verify single tokens, iterative peeling to decompose arbitrary strings. But decompose *what*?

Brute-forcing all possible byte strings of length 1-64 is astronomically large, and our decomposition is linear per string, so even clever generation strategies hit the API wall fast (2000/min rate limit). Early experiments with generated data and public datasets proved to be intractable very quickly, though we did pull out a few confirmed tokens as proof of life.

### Cross-tokenizer mining

I needed a way to narrow the search space to something that would run in days instead of centuries.

After some back-and-forth with Claude, I arrived on cross-tokenizer mining: decode vocab items from existing BPE tokenizers (tiktoken, HuggingFace models), test each against Claude with sandwich counting, keep only single-token hits.

Tokenizers trained on overlapping internet/programming corpora converge on many of the same subwords. This isn't surprising if you think about it from a compression angle, and the Anthropic-specific tokens are likely not dominant in the distribution.

| Source | Vocab size | Hit rate | New tokens found |
|---|---|---|---|
| tiktoken cl100k_base (GPT-4) | 100K | ~46% | ~29,000 |
| tiktoken o200k_base (GPT-4o) | 200K | ~15% | ~4,000 |
| 11 HuggingFace US + China models | 150-250K each | 2-74% | ~3,800 |

Sorting multilingual candidates by cross-tokenizer frequency (tokens appearing in more tokenizers checked first) gave a 74% hit rate on the first 1,000 candidates, declining to ~2% by 20K.

### Long tail

The long-tail vocabulary recoveries here were interesting:

- Re-checking all digit-starting candidates recovered ~1,006 tokens — almost all 3-digit numbers (`916`, `030`, `271`) are single tokens.
- BPE creates single tokens for specific lengths of repeated characters (`=`, `-`, etc.) up to length 64 with non-monotonic patterns: `"=" * 7` is 2 tokens but `"=" * 8` is 1 (likely a BPE merge-order artifact — these lengths matter for markdown fences and separator lines). Space sequences 1-16, tab sequences 1-4, and newline variants are each single tokens - critical for code indentation accuracy (and token efficiency!)

## Results

The full extraction took 3 days and ~277K API calls.

### Estimator quality (greedy longest-match)

| Corpus | Efficiency ratio (`API tokens / greedy tokens`) |
|---|---:|
| Python source (9 files)| 96.1% |
| Mixed code + docs (9 files)| 95.1% |
| English prose (5 samples) | 99.2% |

Per-file variance is low: individual files land within ~2% of their corpus mean, and the estimator consistently over-segments (predicts more tokens than API), which is desirable for conservative context budgeting (read the Appendix to understand *why* we get this close).

### Conclusion

The final outcome of this project - `ctoc` - is deliberately boring software that just runs a greedy tokenization algorithm on top of our discovered vocabulary. Unknown bytes fall back to 1 token. Fast enough to run as a preflight check in local workflows, or for a coding agent to run as a subprocess.

If you care about exact counts for billing-critical paths, use Anthropic's API. If you care about fast, parallelizable, local (self)context management, this could be good enough (and certainly has scope to close the 3-4% gap).

As always, this depends on current (tested with Claude 4.x) API behavior and can drift if Anthropic changes tokenizer internals.

---

## Appendix

### Why does greedy tokenization do well?

What turned out to be empirically true but not obvious - greedy longest-match and BPE merge-order produce *different segmentations*. Why do the token *counts* nearly converge?

There's a reasonable theoretical picture:

BPE vocabularies are built for greedy compression. [Zouhar et al. (2023)](https://aclanthology.org/2023.findings-acl.38/) formalise BPE training as greedy submodular maximisation of a compression utility. The vocabulary is constructed bottom-up: every multi-character token was formed by merging two shorter tokens that are also in the vocabulary. This hierarchical structure means the longest token at any position tends to be the one BPE would also select.

Byte-level completeness prevents dead ends. BPE vocabularies always include single-byte fallback tokens, so a left-to-right greedy pass can never paint itself into a corner. This eliminates the primary failure mode of greedy algorithms on arbitrary dictionaries.

BPE training also has an implicit left-to-right bias. [Sawada & Goyal (2025)](https://aclanthology.org/2025.emnlp-main.1775/) evaluate merge-list-free left-to-right greedy encoding and find it is often comparable to standard merge-based tokenization, with improvements on some tasks and modest degradations on others.

And where greedy and BPE do disagree, the result is typically a rearrangement of boundaries, not a net increase in tokens. `['hell', 'ooo']` vs `['hello', 'oo']` — different boundaries, same count.

The upshot: for BPE-family tokenizers with byte fallback, greedy and merge-order counting often converge closely in practice when vocabulary coverage is high. The 4-5% gap in `ctoc` is plausibly missing tokens forcing over-segmentation. If the vocabulary were complete, greedy counting would likely be even closer to API counts.
