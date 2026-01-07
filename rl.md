# RL Pipeline for Prover-Verifier Game (PVG)

## Goal
Spec compilation via agentic coding: DSL/config spec → generated code

## Why PVG fits this domain

1. **Verification is tractable** - Non-Turing-complete specs mean correctness can be decided, not just approximated
2. **Constrained output space** - DSL bounds valid code patterns, less room for degenerate solutions
3. **Compositionality** - DSLs have clean semantics, spec → code can be broken into verifiable chunks

## Architecture

```
┌─────────────┐
│  DSL Spec   │
└─────┬───────┘
      │
      ▼
┌─────────────┐     ┌──────────────────┐
│   Prover    │────▶│  Generated Code  │
│   (LLM)     │     └────────┬─────────┘
└─────────────┘              │
      ▲                      ▼
      │              ┌───────────────┐
      │              │   Verifier    │
      │              │ (symbolic +   │
      └──feedback────│  LLM hybrid)  │
                     └───────────────┘
```

## Hybrid Verifier Design

| Check              | Method                              |
|--------------------|-------------------------------------|
| Syntactic validity | Parser/type checker (deterministic) |
| Semantic compliance| DSL interpreter / constraint solver |
| Intent alignment   | LLM (for ambiguous parts)           |

Key insight: RL signal comes from deterministic checks. LLM verifier handles soft constraints only.

## What RL trains

**Prover learns:**
- Code patterns that satisfy DSL constraints
- Edge case handling for spec grammar
- Mapping from spec semantics to implementation

**Reward function:**
- Weighted combination of (hard constraints satisfied) + (soft verifier score)
- Hard constraints: syntax, types, semantic compliance (binary)
- Soft constraints: code quality, intent alignment (continuous)

## Open questions

- [ ] What specific DSL? (Terraform-like, schema definitions, build configs?)
- [ ] What's the target output? (Implementation code, another config, API calls?)
- [ ] Existing spec→code pairs for bootstrapping?
- [ ] Verifier architecture: fully symbolic vs. hybrid?
- [ ] Training stability: curriculum design, population-based training?

## Risks

1. **Mode collapse** - Prover exploits verifier weaknesses rather than producing good code
2. **Verifier bottleneck** - LLM component of verifier may miss subtle bugs
3. **Collusion** - If training both, they may converge to easy-to-check but low-quality solutions

## Alternatives considered

| Approach                  | Pros                        | Cons                          |
|---------------------------|-----------------------------|-------------------------------|
| PVG with RL               | Learns edge cases           | Training complexity           |
| Execution-based feedback  | Ground truth signal         | Only catches runtime failures |
| Verifier as critic (no RL)| Simple, works today         | No learned improvement        |
| Formal spec + SMT solver  | Provably correct            | Limited expressiveness        |
