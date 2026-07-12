# Continuous Loop — Audit Gate and Flexible Re-planning

This reference defines the audit step that runs after every archived slice, and the
triage rules that decide whether to continue, patch the plan, or stop. It encodes a
proven working rhythm: execute → verify → **adversarial audit** → continue or amend.

## Why an audit gate exists

Green tests prove the code does what the tests say — not that the tests ask the right
questions. The audit gate hunts for what the slice's own tests missed. Historical
motivation: a writer module passed 21 enum-focused tests while 7 boundary crashes
(empty update, NULL into NOT NULL, out-of-range epoch poisoning every later read,
bool-as-int) all slipped through. Enum tests cannot catch boundary bugs.

## Audit protocol (per archived slice)

1. **Re-read the diff** of the slice with hostile eyes: list every suspicion —
   empty collections, None, out-of-range values, type impostors (bool passes
   `isinstance(x, int)`), encoding, path traversal, cross-module contract drift.
2. **Probe, don't speculate**: write a throwaway probe script that actually executes
   each suspicion against the real code. Only findings that reproduce count.
   Suspicions that don't reproduce are recorded as "probed, clean".
3. **Triage each confirmed finding** (severity table below).
4. **Record**: append findings to `KNOWN_ISSUES.md` (repo root) with severity,
   reproduction command, root cause, fix plan, and status
   (`open` / `fix@<slice>` / `mitigated` / `accepted` / `fixed@<slice>`).
5. **Clean up**: delete probe scripts; each confirmed finding must become a
   regression test when fixed (reproduction-to-test rule).
6. **Decide the path** (decision table below) and state the decision explicitly.

## Severity triage

| Severity | Definition | Path |
|---|---|---|
| HIGH | crash, data poisoning (one bad row breaks later reads), silent data loss, security | fold into the very next slice as top scope items — fixes before features |
| MEDIUM | wrong behavior, footgun defaults, combo risks (spec-correct pieces that compose unsafely) | schedule into the next natural slice; mitigations may land earlier |
| LOW | hygiene, observability, semantic drift in logs | record; batch later; never blocks continuation |
| DESIGN | audit invalidates a DESIGN/PLAN assumption | stop coding; amend artifacts first (below) |

## Plan amendment (flexible re-planning)

When a finding contradicts DESIGN.md or PLAN.md:

1. Amend the artifact **in place** with the correction and a one-line reason
   (e.g. probe result, measured behavior). Design docs are living documents;
   an amended plan is a healthier plan than a wrong one.
2. If the change invalidates planned SLICEs, re-slice TODO.md before continuing.
3. If the change crosses PARTs, update PLAN.md and affected part DESIGNs.
4. **No incident needed** for routine amendments. Open an incident only when the
   Hard Stops list is hit (unsafe diff, rejected outcome, broad rework, blocked).
5. Verified empirical facts belong in the DESIGN (e.g. a "probe findings" table)
   so later implementers don't "fix" code back to broken intuition.

## Continuation contract

Before auto-continuing to the next slice, state in one short block:

- **Audited**: what was probed (and what was skipped, honestly)
- **Found**: confirmed findings + severities (or "clean")
- **Path**: continue / fixes folded into next slice / plan amended (what+why)
- **Next**: which SLICE is being promoted

Pause and report to the user instead of continuing when:

- a PART completes (gate review belongs to the user)
- the next slice needs a user decision (open question, credentials, environment)
- the next slice has no DESIGN authority yet
- any Hard Stop condition appears

## Anti-patterns

- Auditing by re-reading code and declaring it fine without executing anything
- Fixing HIGH findings "later" while continuing to build on poisoned foundations
- Opening incidents for ordinary design corrections (inflates incident noise)
- Letting audit scope creep into a full re-review of all prior slices — audit the
  new slice plus its contract boundaries with existing modules
- Silent auto-continuation without the continuation contract block
