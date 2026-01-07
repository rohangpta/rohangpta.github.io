# The Thesis: Leveraged Software Delivery

## Part I: The Entropy Problem

### Software is Drowning in Complexity

Technical debt is not a metaphor. It's thermodynamics.

The Consortium for Information & Software Quality estimates the cost of poor software quality in the US at $2.41 trillion annually. Of that, $1.52 trillion is accumulated technical debt—the compounding interest on decades of shortcuts, undocumented decisions, and systems held together by tribal knowledge.

This isn't a bug. It's the natural state of software under the current model.

### The Second Law of Software

Entropy in a closed system always increases. Software systems are no different. Every feature adds complexity. Every dependency adds risk. Every engineer adds coordination overhead.

The traditional response? Add more engineers. Which adds more complexity. Which requires more engineers.

The IT services industry—TCS, Cognizant, Accenture, Infosys—is a $1.4 trillion machine built on this doom loop. They staff 10, 50, 100+ engineers on regulatory reporting programs. They bill by the hour. They benefit when complexity grows.

Here's the uncomfortable truth: **people are complexity**.

Those 100 TCS staffers aren't just expensive—they're entropy. Each one adds code in a slightly different style. Undocumented decisions. Knowledge silos. Turnover and re-onboarding. The meetings to align them are complexity. The artifacts they produce are complexity.

System integrators don't fight entropy. They *are* entropy.

---

## Part II: The Agent Inflection

### LLMs Crossed a Threshold

Large language models can now:
- Explore unfamiliar codebases
- Write integrations to undocumented APIs
- Generate tests that validate behavior
- Iterate on failures without human intervention
- Reason about specifications and acceptance criteria

This isn't "autocomplete for code." This is the foundation of goal-directed software generation.

### Agents as Compilers, Not Assistants

The industry is using LLMs wrong. They're building "AI assistants" that help humans write code faster. Copilots. Chatbots. Pair programmers.

This is thinking too small.

The real opportunity: **agents that compile goal specifications directly into working software**.

Not "help me write this function." Instead: "here is the obligation, here are the acceptance criteria, here is the SLA. Go."

This is goal-complete programming—a declarative contract that specifies *what* must be true, compiled by an agent that figures out *how*.

### Goal-Completeness

Turing-completeness gave us machines that can compute anything computable. Goal-completeness gives us machines that can pursue any specifiable goal.

Just as every electronic device converged on Turing-complete chips (your toothbrush and the Apollo guidance computer are architecturally identical), intelligent systems will converge on goal-complete architectures.

We're building a goal-specification language for a narrow but massive domain: regulated, spec-heavy enterprise work. The agent is the goal-complete runtime. The contract is the program.

---

## Part III: The Business

### Obligations Engine

A platform that executes spec-driven IT services contracts with agents and a thin expert team, not armies of humans.

**The stack:**

```
┌─────────────────────────────────────────────┐
│  Obligations DSL                            │
│  - Declarative contracts                    │
│  - Systems, data, SLAs, acceptance criteria │
│  - Composable: import finra/rule-7450       │
│  - Python as first-class escape hatch       │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  Agentic Compiler                           │
│  - Parses contract                          │
│  - Explores client environment              │
│  - Generates code, tests, monitors          │
│  - Iterates until acceptance criteria pass  │
│  - Structured errors when blocked           │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  Verification & Risk Layer                  │
│  - Maps obligation → artifact → evidence    │
│  - Prices contracts by expected failure     │
│  - We own the downside                      │
└─────────────────────────────────────────────┘
```

### The Constraint That Makes It Work

The agent can write arbitrary code to interface with messy client environments—legacy APIs, undocumented services, weird data formats. But it must produce artifacts that conform to our platform: approved dependencies, standardized formats, minimal surface area.

Entropy stays outside. Our system stays clean.

This isn't a limitation. It's the core of the business model. Because we price risk, we're incentivized to keep entropy low. Every failure is margin erosion. We're structurally obsessed with clean, minimal, predictable output.

### Risk Pricing and Software Insurance

Every contract is priced by expected failure rate. We own the downside—if software fails and the agent can't fix it, that's on us.

This is "software insurance." Enterprises hate risk. Traditional SIs have vague SLAs and finger-pointing when things break. We say: here's the contract, here's the SLA, here's the payout if we miss it.

We're not a vendor. We're a counterparty.

To price risk accurately, we need:
- Task complexity (how many unknowns?)
- Environment stability (how often does their infra change?)
- Data quality (garbage in = high failure rate)
- Historical success rate on similar contracts

Each contract we execute improves the model. The flywheel is data, not headcount.

---

## Part IV: Why These Domains

### Isomorphism with Agent Capabilities

We're not applying agents to arbitrary services work. We're selecting work that is *isomorphic to what agents do well*.

The domains we target share a critical property: **the solution is code, the spec is code, and the verification is code**.

| Domain | Why it's spec-friendly | Why agents grok it |
|--------|------------------------|-------------------|
| Regulatory reporting | Regulations are specs—precise, written, verifiable | Rule in → code out → test validates |
| Data migrations | Source + target schema = complete spec | Deterministic transforms, equivalence testing |
| ETL/Pipelines | Inputs, outputs, transformations defined | Pure functions, fully observable |
| Infra modernization | IaC is already declarative | Current state → target state, diffs are code |

The agent never leaves the world it understands. No fuzzy judgment. No subjective success criteria. Binary, machine-verifiable outcomes.

### Why Regulated Finance First

- **Obligations are explicit**: Regulations are specs that already exist. We're not inventing requirements—we're making existing ones executable.
- **High pain**: Compliance costs, audit pressure, slow time-to-change. They're spending millions on TCS already.
- **High trust bar**: Our risk model is a feature, not a bug. They need counterparties who stand behind their work.
- **Expandable**: Same patterns apply to healthcare, insurance, government—anywhere with regulatory overhead and legacy systems.

### The SOW Structure IS The Spec Structure

Every IT services contract follows the same skeleton. We analyzed SOWs from TCS, Accenture, Cognizant, Infosys, and government contracts. The pattern is universal:

| SOW Section | What It Contains | DSL Equivalent |
|-------------|------------------|----------------|
| Scope | What's in/out | `contract { scope { ... } }` |
| Deliverables | Specific artifacts (reports, pipelines, docs) | `deliverables { ... }` |
| Milestones | Phase gates with dates (typically 4-5) | `milestones { ... }` |
| Acceptance Criteria | How you know it's "done" (UAT, testing) | `oracles { ... }` |
| SLAs | Uptime, response time, defect resolution | `sla { ... }` |
| Payment | Milestone-based (20/30/20/20/10 typical) | `pricing { ... }` |
| Change Management | How scope changes are handled | `change_policy { ... }` |
| Roles | Who does what (RACI) | `responsibilities { ... }` |

**The key insight:** ~80% of contract structure comes from regulation, not client-specific requirements. FINRA reporting at Bank A looks nearly identical to FINRA reporting at Bank B. The variance is:
- Which systems hold the data (Snowflake vs Oracle vs mainframe)
- Internal naming conventions
- Edge cases specific to their business

This is why the flywheel works. We're not learning "how to do Bank A's reporting." We're learning "how to do FINRA reporting" once, then adapting to each client's plumbing.

**The economic leverage:**

TCS charges similar fees for Contract 1 and Contract N. Their cost is linear (bodies).

Our cost for Contract N is marginal (just adapters). Our margin expands with each contract in the same regulatory domain.

```
Contract 1: Learn FINRA reporting + Bank A adapters
Contract 2: Reuse FINRA reporting + Bank B adapters (faster)
Contract 3: Reuse FINRA reporting + Bank C adapters (faster still)
...
Contract N: FINRA reporting is a library, just write adapters
```

**What we formalize:**

The DSL isn't invented in a vacuum. It's a direct encoding of what these SOWs already contain—just executable instead of a Word document that 50 people interpret differently.

---

## Part V: The Flywheel

### How It Compounds

1. **We price risk → we minimize entropy**
   - Opposite of SIs who benefit from complexity
   - Every failure hurts margin, so we obsess over clean output

2. **More contracts → more data → better pricing**
   - Each engagement yields DSL specs, agent traces, failure modes
   - Repeated patterns become standard library primitives
   - Risk model improves with every contract

3. **Tighter platform → lower failure rate → more competitive pricing**
   - We underprice SIs because our cost structure is agents, not armies
   - Enterprises get guaranteed outcomes, not best-effort consulting

4. **Land and expand**
   - Start with one report → prove it works → expand to more obligations
   - Platform becomes system of record for "what must be true"

### The Discipline

Only take work that fits the obligations domain: reg/risk/reporting, migrations, compliance-driven modernization.

The temptation will be to take adjacent work that doesn't fit the model. Resist. The flywheel compounds when the work is homogeneous. It fragments when you chase revenue outside the core.

---

## Part VI: The Long View

### What We're Really Building

This isn't just a services business that uses AI. It's infrastructure for a new market.

**The parallel to financial markets:**

| Financial Markets | Talent/Services Markets |
|-------------------|------------------------|
| Manual traders | Manual consultants |
| Quants + models | Agents + platforms |
| Securities = tokenized ownership | Contracts = tokenized work |
| Market makers provide liquidity | We provide delivery liquidity |
| Pricing via models | Pricing via risk models |
| Leverage at platform level | Leverage at platform level |

As financial markets got more efficient, value got tokenized and contractualized. As talent markets get more efficient (via AI), services work will get tokenized and contractualized.

Today: "We need 50 people for 6 months" — fuzzy, labor-denominated, unpriced risk.

Tomorrow: "Contract #4721: T+1 equity report, SLA 99.9%, acceptance criteria X/Y/Z" — discrete, outcome-denominated, precisely priced.

### The Quant Transformation

What we're doing to software services is what the quants did to traditional finance.

Quants replaced traders with models—and made markets more efficient. We're replacing consultants with agents—and making software delivery more efficient.

- Efficient pricing of outcomes
- Efficient allocation of compute instead of headcount
- Efficient compression of complexity

Citadel Securities is built on massive platform leverage—a thin team of exceptional people supported by infrastructure that turns market-making into a math problem.

We're building the same for IT services. Obligations in, verified software out, risk priced precisely.

### The Endgame

**Year 1**: Services company with a platform. Founder-led sales, design partners, prove the model works.

**Year 3**: Platform company with services. Clients want self-serve. DSL and standard library are mature. Risk pricing is accurate.

**Year 5**: The system of record for enterprise obligations. If it must be true in production, it's specified in our DSL.

**Year 10+**: Maybe an exchange. Marketplace for contracts. Secondary markets for obligations. Reinsurance for software risk.

The IT services industry is a $1.4 trillion market with $600B+ in market cap, built on labor arbitrage and entropy accumulation. The cost of poor software quality is $2.4 trillion annually, with $1.5 trillion in technical debt.

We're not competing with TCS. We're attacking the cost of the complexity they create.

---

## Part VII: Why Now, Why Me

### Why Now

- **LLMs crossed the threshold**: Agents can explore, write, iterate, reason. Two years ago this was impossible.
- **Enterprises are ready**: AI fatigue from chatbots. Hungry for outcomes, not demos.
- **SIs are vulnerable**: Their model is labor arbitrage. Ours is leverage.
- **Regulatory pressure increasing**: More rules, faster timelines, same headcount.

### Why Me

I was a platform engineer at Citadel Securities. I built an internal coding-agent platform that:
- Generated "a year's worth of code coverage overnight" on production systems
- Reached ~100 weekly active users
- Became core to the firm's AI platform story
- Put me in weekly contact with the CTO and in front of the CEO

I've orchestrated LLM agents against serious production codebases. I've seen what works and what doesn't. I've been obsessed with spec-driven development and software entropy for years.

I'm leaving Citadel in January 2025 with 4-5 years of personal runway. I can bootstrap, be selective, and build this the right way.

---

## The Core Belief

System integrators add entropy. We remove it.

The IT services industry exists because software is hard to specify and expensive to maintain. But specifications are just goals. And we're entering the era of goal-complete AI—systems that take an arbitrary goal and output actions to achieve it.

The endgame: a world where business obligations compile directly into verified, running software. No armies of consultants. No decades of accumulated debt. Just contracts and agents.

This is leveraged software delivery.

Macro thesis (core): software delivery is shifting from a labor market to
a capital market.

For 30 years, “building software” has been financed implicitly through
headcount: long-lived teams, multi-year programs, and system integrators paid
for time. That model treats engineering effort as the asset and tolerates
massive variance in outcome. AI changes the physics: execution becomes cheap,
fast, and increasingly automatable. When execution is cheap, the scarce
resource becomes risk-bearing capacity: who can commit to outcomes, absorb
variance, and continuously prove correctness as the world changes.

That is the financialisation of software: not “Wall Street for code,” but the
emergence of financial primitives around software obligations.

Thesis statement (one paragraph)

Software is becoming a financial product. As AI drives the marginal cost of
code execution toward zero, value migrates from writing code to underwriting
outcomes: specifying obligations, pricing delivery and maintenance risk,
guaranteeing SLAs, and producing continuous audit-grade proof. The dominant
unit of production shifts from bespoke projects and time-and-materials staffing
to standardized contractual obligations executed by automated runtimes. Over
time, software work becomes more like an asset class: obligations are
standardized, risk is priced, performance is measured, and vendors
differentiate by their ability to underwrite and continuously verify results.
