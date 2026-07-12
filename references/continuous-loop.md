# Continuous Loop — Audit Gate and Flexible Re-planning

This reference defines the audit step that runs after every archived slice, and the
triage rules that decide whether to continue, patch the plan, or stop. It encodes a
proven working rhythm: execute → verify → **adversarial audit** → continue or amend.

## When the loop fires (non-negotiable)

The loop fires **automatically** the moment slice verification passes — not when
the user asks for it. From that moment, Archive → Audit → decide-path is one
uninterrupted sequence in the same turn:

- Tests green is NOT "done". A slice is done only after its done/ snapshot is
  written AND the audit gate has run.
- Ending the turn after Verify but before Audit is a protocol violation, the
  same class of error as skipping verification itself.
- If the audit result is `clean` or `minor`, promote the next planned SLICE and
  keep executing without waiting for user input.
- Stop ONLY at a natural pause point (PART complete, user decision needed,
  missing DESIGN for the next slice) or a Hard Stop — and say which one applies.

**Enforcement mechanism**: when promoting a slice into CURRENT.md, the executor
must register the tail steps as explicit work items alongside the implementation
items — at minimum: `verify`, `archive done/ snapshot`, `run audit gate`,
`decide path / promote next slice`. A todo list that ends at "verify" is
malformed; the premature stop happens because the plan itself stopped early.

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

## Minimum audit bar (what "audited" must mean)

Pausing for a user decision or an incident is always legitimate — but ONLY after
a real audit. An audit that produced no executed probes is not an audit. Before
reporting `clean` or pausing, all of the following must hold:

1. **Suspicion list exists**: the diff re-read produced a written list of
   concrete suspicions (or an explicit "no suspicious surfaces because X").
   An empty list with no justification is a skipped audit.
2. **Every suspicion was executed**: each item is either `reproduced` (with
   command + output) or `probed, clean` (with the probe that failed to
   reproduce it). "Read the code, looks correct" is forbidden as a resolution.
3. **Boundary classes were covered**: empty input, None/null, out-of-range
   values, type impostors, encoding, and cross-module contract drift were each
   considered — covered by a probe or explicitly ruled out with a reason.
4. **Evidence is durable**: the done/ snapshot names what was probed, what was
   found, and what was skipped. `Audited: everything, Found: clean` with no
   probe list is malformed evidence.

If time pressure forces a shallower audit, say so explicitly ("audit shallow:
only X and Y probed, Z skipped because ...") — an honest shallow audit is
acceptable at a pause point; a dressed-up empty one is not.

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

A pause does not lower the audit bar. The slice being paused on must still pass
the Minimum audit bar above BEFORE the pause is reported — pausing is a reason
to stop promoting the next slice, never a reason to skip or thin out the audit
of the finished one. The pause report must include the same continuation
contract block (Audited / Found / Path / Next), with Path = "paused: <reason>".

## Anti-patterns

- Auditing by re-reading code and declaring it fine without executing anything
- Thinning out the audit because a pause point is coming ("user will review it
  anyway") — the pause report depends on the audit being real
- Fixing HIGH findings "later" while continuing to build on poisoned foundations
- Opening incidents for ordinary design corrections (inflates incident noise)
- Letting audit scope creep into a full re-review of all prior slices — audit the
  new slice plus its contract boundaries with existing modules
- Silent auto-continuation without the continuation contract block
