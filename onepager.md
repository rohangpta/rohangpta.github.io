# Leveraged Coding Agents for Software Delivery

## The Problem: Entropy is Eating Enterprise IT

Technical debt consumes 40% of IT balance sheets and 50% of developer time. Large enterprises—especially in regulated industries—are drowning in:

- **Regulatory change**: New rules, new reports, new controls every year
- **Legacy systems**: Migrations that never finish, debt that compounds
- **IT services contracts**: TCS, Cognizant, Accenture staffing 10-100+ FTEs to maintain sprawling pipelines, scripts, and glue

The traditional model is thermodynamically backwards. System integrators are paid by the hour. They benefit when complexity grows. They *add* entropy.

---

## The Insight: Agents as Compilers, Not Assistants

LLMs have crossed a capability threshold. But the industry is using them wrong—building "AI assistants" that help humans write code faster.

The real opportunity: **agents that compile goal specifications directly into working software**.

Not "help me write this function." Instead: "here is the obligation, here are the acceptance criteria, here is the SLA. Go."

This is goal-complete programming—a declarative contract that specifies *what* must be true, compiled by an agent that figures out *how*.

---

## The Solution: Obligations Engine

A platform that executes spec-driven IT services contracts with **agents + a thin expert team**, not armies of humans.

**Core components:**

1. **Obligations DSL**
   - A machine-readable contract capturing: systems, data, obligations, SLAs, acceptance criteria
   - Declarative: specifies goals and constraints, not implementation steps
   - Composable: import standard regulations (`finra/rule-7450`), extend with custom logic
   - Python as first-class citizen for custom validations and transforms

2. **Agentic Compiler**
   - Parses contract, explores client environment, generates code
   - Iterates autonomously until acceptance criteria pass—no human intervention by default
   - Emits artifacts: pipelines, tests, monitors, runbooks, audit evidence
   - Structured error reporting when blocked (ambiguity, data quality, access)

3. **Risk Pricing & Verification Layer**
   - Every contract priced by expected failure rate
   - We own the downside—if software fails and agent can't fix, that's on us
   - Built-in "software insurance" creates enterprise trust
   - Obligation → artifact → evidence mapping for auditors

**The constraint that makes it work:**

The agent can write arbitrary code to interface with messy client environments. But it must produce artifacts that conform to our platform—approved dependencies, standardized formats, minimal surface area. Entropy stays outside. Our system stays clean.

---

## Why This Works (The Flywheel)

1. **We price risk → we're incentivized to minimize entropy**
   - Opposite of SIs who benefit from complexity
   - Every failure is margin erosion; we're obsessed with clean, minimal output

2. **More contracts → more data → better pricing**
   - Each engagement yields DSL specs, agent traces, failure modes
   - Repeated patterns become standard library primitives
   - Risk model improves with every contract

3. **Tighter platform → lower failure rate → more competitive pricing**
   - We can underprice SIs because our cost structure is agents, not armies
   - Enterprises get guaranteed outcomes, not best-effort consulting

4. **Land and expand**
   - Start with one report/migration → prove it works → expand to more obligations
   - Platform becomes the system of record for "what must be true"

---

## The Wedge: Regulated Finance

**ICP (v1):** Mid-to-large financial institutions with regulatory reporting, legacy pipelines, and active modernization efforts.

**Why finance:**
- Obligations are explicit (regulations = specs that already exist)
- High pain (compliance costs, audit pressure, slow time-to-change)
- High trust bar (our risk model is a feature, not a bug)
- Expandable (same patterns apply to healthcare, insurance, government)

**Example engagements:**

| Scope | Timeline | Price |
|-------|----------|-------|
| Single regulatory report rebuild (e.g., T+1 equity) | 8-16 weeks | Low-to-mid six figures |
| Risk data mart migration (legacy ETL → Snowflake/dbt) | 3-6 months | Mid-to-high six figures |
| Capability-in-a-box: own build-and-run for a capability under SLA | Setup + retainer | Ongoing |

---

## Why Now

- **LLMs crossed the threshold**: Agents can now explore codebases, write integrations, iterate on failures
- **Enterprises are ready**: AI fatigue from chatbots; hungry for outcomes, not demos
- **SIs are vulnerable**: Their model is labor arbitrage; ours is leverage
- **Regulatory pressure increasing**: More rules, faster timelines, same headcount

---

## Why Me

**Rohan Gupta**
- Platform engineer at Citadel Securities
- Built an internal coding-agent platform that:
  - Generated "a year's worth of code coverage overnight" on production systems
  - Reached ~100 WAUs, became core to the firm's AI platform
  - Put me in weekly contact with the CTO, presented to CEO
- Deep experience orchestrating LLM agents against serious production codebases
- Long-running obsession with spec-driven development and entropy in software systems

**Stage:**
- Leaving Citadel January 2025
- 4-5 years personal runway + access to family capital
- Ability to bootstrap, be selective, raise only to accelerate hiring

---

## The Ask

**Investors:**
- Early-stage partners who believe in AI-native infrastructure, regulated verticals, and thin high-leverage teams
- Capital to hire 2-4 partner-level people (platform + GTM) once wedge is validated

**Partners:**
- GTM leaders who can own relationships in regulated enterprises
- Senior engineers excited to build the DSL, compiler, and verification layers that replace the IT services industry

**Customers:**
- Design partners in finance willing to pilot on a real obligation
- Start with one report, one migration, one capability

---

## The Vision

System integrators add entropy. We remove it.

The IT services industry exists because software is hard to specify and expensive to maintain. But specifications are just goals. And we're entering the era of goal-complete AI—systems that take an arbitrary goal and output actions to achieve it.

The endgame: a world where business obligations compile directly into verified, running software. No armies of consultants. No decades of accumulated debt. Just contracts and agents.

---

What we're doing to software services is what the quants did to traditional finance.

Quants replaced traders with models—and made markets more efficient. We're replacing consultants with agents—and making software delivery more efficient. Efficient pricing of outcomes. Efficient allocation of compute instead of headcount. Efficient compression of complexity.

The IT services industry is a $1.4T market—$600B+ in market cap across the top players alone—built on labor arbitrage and entropy accumulation. But the real number is bigger: the cost of poor software quality in the US is $2.4T annually, with $1.5T in technical debt alone. We're not just competing with TCS. We're attacking the cost of the complexity they create. It's ripe for the same transformation.

This is leveraged software delivery. This is the future of IT services.
