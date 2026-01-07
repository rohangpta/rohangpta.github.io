# Vision: The Controlled Entropy Machine

## The Core Insight

Traditional "vibe coding" fails because agents operate in chaotic, uncontrolled environments. Infinite dependencies, unknown state, flaky builds, sparse reward signals. The search space is unbounded and the feedback is noisy.

We flip this entirely.

We build a **perfectly observable sandbox**—a controlled entropy environment where agents can actually learn and improve. Then we train agents via self-play (PVG, GRPO, RL) to compile specs into working software.

The sandbox isn't a limitation. It's the entire point.

---

## The Stack

### Everything Is Code

We reduce all management complexity by turning everything into code:

| Layer | Implementation |
|-------|----------------|
| Application logic | Python (default), C++ (when perf needed) |
| Infrastructure | Terraform (all clouds) |
| Build/test/deploy | Bazel (hermetic, reproducible) |
| Observability | Code (not config files in Datadog) |
| Runbooks | Code (not wiki pages) |
| CI/CD | Clean, checked pipelines |

When we own the code, we can make it precise. When it's precise, we can make it observable. When it's observable, agents can reason about it.

### The Sandbox Properties

```
┌─────────────────────────────────────────────────────────┐
│                  Your Sandbox                           │
│                                                         │
│   ✓ Hermetic builds (Bazel)                            │
│   ✓ Fully observable (everything is code)              │
│   ✓ Constrained patterns (your libs, your style)       │
│   ✓ Known dependency graph (no surprise imports)       │
│   ✓ Deterministic (same input = same output)           │
│   ✓ Reproducible (can replay any state)               │
│                                                         │
│   Entropy: CONTROLLED                                   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Why This Enables RL/Self-Play

| Problem | Vibe Coding (Wild) | Your Sandbox |
|---------|-------------------|--------------|
| Environment | Messy, unknown deps | Hermetic, known, fixed |
| Observability | Logs maybe? | Everything visible |
| Reward signal | "Does it run?" (sparse) | Oracles (dense, precise) |
| Search space | Infinite | Constrained to your patterns |
| Reproducibility | "Worked yesterday" | Guaranteed identical |
| Credit assignment | No idea what broke | Exact oracle, exact line |

---

## The Training Loop

### Prover-Verifier Game

```
Spec (goal)
    ↓
┌─────────────────────────────────────┐
│  Prover (Generator Agent)           │
│  - Takes spec                       │
│  - Generates code in your patterns  │
│  - Goal: satisfy all oracles        │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│  Sandbox Execution                  │
│  - Bazel build                      │
│  - Run in isolated environment      │
│  - Full observability               │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│  Verifier (Oracle Suite)            │
│  - Binary: pass/fail                │
│  - Attributable: which oracle broke │
│  - Dense signal: not just "crashed" │
└─────────────────────────────────────┘
    ↓
Reward signal → Agent improves
```

### The Self-Play Dynamic

- **Prover** gets better at generating valid code
- **Verifier** gets better at catching subtle failures
- Both improve because environment is **fixed and clean**
- No moving target, no environment shift, no "works on my machine"

---

## The Pluggability Layer

### Clean Core, Messy Adapters

The generated software must integrate with messy enterprise environments. We handle this by strict separation:

```
┌─────────────────────────────────────────────────────────┐
│  Your Platform (clean, controlled)                      │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Generated Core Logic                            │   │
│  │  - Standard interfaces                           │   │
│  │  - Your patterns only                           │   │
│  │  - Fully observable                             │   │
│  └─────────────────────────────────────────────────┘   │
│                        │                                │
│                        ▼                                │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Adapter Layer                                   │   │
│  │  - Auth adapters (Kerberos, OAuth, certs, etc)  │   │
│  │  - Format adapters (XML, JSON, CSV, legacy)     │   │
│  │  - Protocol adapters (SFTP, API, Kafka, MQ)     │   │
│  │  - Retry/circuit breaker/fail-fast              │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│  Client Environment (messy)                             │
│  - Legacy APIs                                          │
│  - Weird auth                                           │
│  - Undocumented endpoints                               │
│  - Mainframes from 1987                                 │
└─────────────────────────────────────────────────────────┘
```

### Fail-Fast Semantics

Agent needs to know immediately when blocked vs. when to retry:

```
connection "client_snowflake" {
  on_error {
    auth_failure    = fail_fast("AUTH_WALL")      # Stop, escalate
    timeout         = retry(max=3, backoff=exp)   # Transient, retry
    permission      = fail_fast("PERMISSION")     # Stop, escalate
    rate_limit      = retry(max=10, backoff=exp)  # Expected, wait
    unknown         = escalate("UNKNOWN")         # Human needed
  }
}
```

---

## The Higher-Level Language

### Why It Emerges

Because we control everything below, we can abstract it away:

```
What the customer writes (DSL):

    report "t1_equity" {
      from snowflake.trades
      to finra.sftp
      where trade_date = T-1
      validate completeness, accuracy
      sla 99.9%
    }

What gets generated (hidden):

    - 500 lines of Python pipeline code
    - Terraform for infrastructure
    - Bazel BUILD files
    - Oracle definitions
    - Monitoring/alerting code
    - Runbooks for incident response
```

### The Language Isn't the Product

The language is the **interface** to:
- The controlled sandbox
- The trained agent
- The risk model
- The execution guarantee

It's valuable because it's forged against real contracts, not invented in isolation.

---

## Dependency Graph as First-Class Citizen

### Breaking Down Apps

We reduce management complexity by decomposing applications into explicit dependency graphs:

```
app "t1_report" {
  inputs {
    trades   = source.snowflake.trades
    ref_data = source.s3.reference
  }

  outputs {
    report = sink.sftp.finra
    audit  = sink.internal.evidence
  }

  depends_on {
    enrichment = app.counterparty_enricher
    validation = app.trade_validator
  }

  runtime {
    schedule = "0 14 * * *"
    timeout  = 30m
    retry    = 3
  }
}
```

### Why This Matters

1. **Agent can reason about topology** - Not just files, but system structure
2. **Refactoring is structured** - Move subgraphs between environments
3. **Failure isolation** - One app fails, blast radius is known
4. **Incremental migration** - Start with leaf nodes, work inward

---

## The Flywheel (Technical)

```
Customer contracts
       ↓
Real specs to compile
       ↓
Agent attempts in sandbox
       ↓
Perfect signal (oracle pass/fail, full observability)
       ↓
RL/GRPO improves agent
       ↓
Better agent = more contracts serviceable
       ↓
More contracts = more specs = more signal
       ↓
Repeat
```

### The Moat

Not the DSL (copyable).
Not the agent (commoditizing).
Not the customer relationships (temporary).

**The moat is: a perfectly controlled training environment with real-world specs flowing through it.**

We're building the gym for code agents. And getting paid to generate training data.

---

## Managed Vibe Coding

The tagline:

> **Managed**: We own the runtime, we own the SLA, we own the risk
> **Vibe**: Declare the goal, agent figures out the how
> **Coding**: But it's all code underneath—auditable, versionable, deterministic

The pitch:

> "You tell us what you need. We deliver working software.
> If it breaks at 3am, our agent fixes it before you wake up.
> If it can't, we pay the SLA penalty.
> You never hire a TCS contractor again."

---

## What We're NOT Building

- A toy language for academics
- An "AI coding assistant"
- A chatbot that helps you write code
- A platform that requires enterprises to change everything

## What We ARE Building

- A controlled environment where agents can actually learn
- A business where every contract improves the agent
- A language forged against real customer pressure
- Leverage, not labor
