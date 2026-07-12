---
name: beacon-dev-workflow
description: Repository-local Beacon workflow for plan/design/slice/execute/verify/audit/recover/archive work through .beacon/. Runs a continuous loop between slices (adversarial audit gate, flexible re-planning) and supports multi-agent/multi-person git collaboration (slice claims, disjoint Files-scope, merge waves). Use when creating or following Beacon artifacts, promoting a slice to CURRENT.md, verifying or auditing a slice, coordinating parallel slices across branches, handling recovery, or archiving completed work.
metadata:
  origin: silavater-beacon
---

# Beacon Dev Workflow

Use this skill to make repository work auditable through `.beacon/`: plan, design, slice, execute one active slice, verify, recover, and archive.

## Trigger

- user mentions Beacon, `.beacon/`, PLAN, PART DESIGN, TODO slices, CURRENT, UnitTestCore, incidents, recovery, or archive
- work needs a durable plan before implementation
- active work must be resumed, verified, recovered, or archived
- backlog or ideas need triage into executable work

## Read Order

1. Read `AgentRule.md` or equivalent project rules if present.
2. If `.beacon/` is missing, initialize planning; do not code yet.
3. Read `.beacon/CURRENT.md` if present.
4. Read the active `.beacon/parts/part-XXX/DESIGN.md`.
5. Read the active `.beacon/parts/part-XXX/TODO.md`.
6. Read `.beacon/BACKLOG.md` only for triage, never as execution permission.
7. Read `.beacon/incidents/` only when CURRENT points to recovery or conflict context is needed.
8. Read `.beacon/done/` only when historical evidence is needed.

## Workflow

0. **Architect** (when the project needs system-level design): write/amend the
   repo's design authority docs per `references/architecture-docs.md`; PLAN.md
   executes them and mirrors their build order.
1. **Plan**: maintain `.beacon/PLAN.md` as the long-term PART map.
2. **Design**: create one design authority at `.beacon/parts/part-XXX/DESIGN.md` before executable TODO work.
3. **Slice**: create `.beacon/parts/part-XXX/TODO.md` with verifiable SLICEs.
4. **Promote**: expand exactly one ready SLICE into `.beacon/CURRENT.md`.
5. **Execute**: implement only the allowed scope in CURRENT.
6. **Verify**: run or report the UnitTestCore target and manual QA status.
7. **Audit**: adversarially back-check what was just built (see Continuous Loop below and `references/continuous-loop.md`).
8. **Recover**: open an incident when work becomes unsafe, invalid, blocked, drifting, or verification fails non-trivially.
9. **Archive**: snapshot completed CURRENT/TODO and verification evidence under `.beacon/done/`.

## Continuous Loop (autopilot between slices)

**Trigger point: the moment a slice's verification passes.**
`Verify → Archive → Audit → continue-or-pause` is ONE atomic sequence — never end
the turn between these steps. Finishing Verify (tests green) is NOT a valid
stopping point; a slice without Archive + Audit is an incomplete slice, and
stopping there is a workflow violation. The only legitimate exits are the
Natural pause points and Hard Stops listed below.

After archiving a slice, do NOT stop by default. Run the loop:

```
Execute slice → Verify (tests green) → Archive →
  AUDIT (adversarial back-check, references/continuous-loop.md) →
    ├─ clean          → promote next planned SLICE → continue automatically
    ├─ minor issues   → log to KNOWN_ISSUES.md with severity + repro →
    │                   fold fixes into the NEXT slice's scope (fixes before features) → continue
    ├─ design flaw    → STOP executing → amend DESIGN.md (and PLAN.md if cross-part) →
    │                   re-slice if needed → then continue
    └─ hard stop hit  → ask user / open incident (unchanged Hard Stops rules)
```

Loop rules:

- **Audit is evidence-based, not opinion-based**: write throwaway probe scripts that
  actually execute suspected failure paths; only report findings that reproduce.
  Delete probes afterwards; convert every confirmed finding into a regression test.
  The audit must meet the Minimum audit bar in `references/continuous-loop.md` —
  and this applies equally when pausing for a user decision or incident: pausing
  never excuses a thin audit of the slice just finished.
- **Flexible severity triage** decides the path: crash/data-poisoning = fix before
  next slice; wrong-behavior = schedule into next slice; design contradiction =
  amend the plan artifacts before any further code.
- **Plan amendments are normal, not failures**: when audit invalidates a DESIGN
  assumption, update DESIGN.md (and PLAN/TODO) in place, note the reason, and keep
  going. Do not open an incident for routine plan corrections — incidents are for
  unsafe/blocked/drifting work.
- **Natural pause points** (report to user instead of auto-continuing): a PART
  completes, a user decision from Open Questions blocks the next slice, credentials
  or environment actions are needed, or the next slice's DESIGN does not exist yet.
- Every auto-continuation must state: what was audited, what was found, why it is
  safe to continue (or what was amended).
- Under collaboration, the loop runs at two levels: each worker audits its own
  slice branch before merge; the Lead runs an integration audit (cross-slice
  contract probes + full regression) after each merge wave (`references/collaboration.md`).

## State Rules

- `.beacon/CURRENT.md` is the only active executable authority.
- `BACKLOG.md` is never executable permission.
- A PART `DESIGN.md` must exist before that PART `TODO.md` can be treated as executable.
- Only one SLICE may be active at a time **per worktree**; parallel slices across
  worktrees require claims with disjoint Files-scope (`references/collaboration.md`).
- Every SLICE must have a verification target before implementation.
- `CURRENT.md` must stay short; history belongs in `done/` or `incidents/`.
- Completed CURRENT and PART TODO states must be archived.
- If CURRENT conflicts with PLAN, DESIGN, TODO, BACKLOG, done, or incidents, stop and reconcile before implementation.
- Under collaboration: PLAN and DESIGN are single-writer (Lead); workers propose
  changes via BACKLOG or audit findings, never by direct edits on worker branches.

## Hard Stops

Stop and ask or open an incident before continuing when:

- requirements have multiple reasonable interpretations
- PART design authority is missing
- selected SLICE lacks verification target or done gate
- implementation would exceed CURRENT allowed scope
- scope drift, invalid design assumption, unsafe diff, rejected outcome, or non-obvious verification failure appears
- rollback, abandon, destructive cleanup, or broad rework is being considered
- manual QA is needed but cannot be reported honestly

## Reference Routing

- Workflow structure, artifact authority, and closure rules: `references/workflow-structure.md`
- Artifact responsibilities and templates: `references/beacon-artifacts.md`
- SLICE contract, sizing, split/merge rules: `references/slice-contract.md`
- Audit gate, severity triage, flexible re-planning: `references/continuous-loop.md`
- Multi-agent/multi-person git collaboration (claims, Files-scope, waves, merge protocol): `references/collaboration.md`
- Architecture/design-doc writing standard (authority hierarchy, probe-verified facts, bilingual tech specs): `references/architecture-docs.md`
- Incident V1 and recovery gates: `references/recovery-protocol.md`
- UnitTestCore V1, manifest, and QA reporting: `references/verification.md`
- Optional helpers: `scripts/init_beacon.ps1`, `scripts/UnitTestCore.ps1`

## Verification

Before claiming completion, prove:

- exactly one executable CURRENT exists or the state is intentionally planning-only
- BACKLOG was not used as execution permission
- changed Beacon artifacts match their reference responsibilities
- verification command or manual QA report is named
- incidents were opened/resolved when recovery rules required them
- the audit gate ran for each archived slice (findings logged or "probed, clean"),
  and every auto-continuation included the continuation contract block
