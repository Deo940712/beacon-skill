# Beacon Artifacts

This reference defines `.beacon/` artifact boundaries. Keep active files short and move history to `done/` or `incidents/`.

## V1 Layout

```txt
.beacon/
  PLAN.md
  CURRENT.md
  BACKLOG.md
  parts/
    part-001/
      DESIGN.md
      TODO.md
  done/
    part-001/
      part-001-slice-001-done-current.md
      part-001-done-todo.md
      verification-report.md
  incidents/
    incident-YYYY-MM-DD-part-001-slice-001-short-name.md
  verification/
    manifest.json
    UnitTestCore.ps1
```

Do not add optional `decisions/` or `reports/` in V1 unless the current project explicitly needs them.

## PLAN.md

Long-lived plan across multiple PARTs.

Must include:

- project goal
- non-goals
- PART list and status
- success criteria
- global risks
- global verification strategy

Must not include:

- detailed implementation steps for every SLICE
- long completion logs
- incident details
- raw command logs

Template:

```md
# Beacon Plan

## Project Goal

## Non-goals

## PARTs

| PART | Status | Goal | Design | TODO |
| --- | --- | --- | --- | --- |
| part-001 | planned | ... | `.beacon/parts/part-001/DESIGN.md` | `.beacon/parts/part-001/TODO.md` |

## Success Criteria

## Global Risks

## Global Verification Strategy
```

## parts/part-XXX/DESIGN.md

Design authority for one PART. This file must exist before that PART's TODO is executable.

Must include:

- PART goal
- non-goals
- assumptions
- design options
- chosen design
- diagrams when flow, state, data, architecture, or sequence is hard to explain in text
- verification targets
- unit test strategy
- manual QA strategy
- risks
- open questions

Template:

```md
# part-001 DESIGN

## Goal

## Non-goals

## Assumptions

## Design Options

## Chosen Design

## Verification Targets

## Unit Test Strategy

## Manual QA Strategy

## Risks

## Open Questions
```

## parts/part-XXX/TODO.md

Slice map for exactly one PART. It lists all planned SLICEs for that PART, but does not duplicate CURRENT-level execution detail.

Each SLICE must include:

- id
- status
- goal
- candidate scope
- forbidden scope
- verification target
- done gate

Template:

```md
# part-001 TODO

Design authority: `.beacon/parts/part-001/DESIGN.md`

## SLICE Map

### part-001-slice-001: Short Name

Status: planned

Goal:

Candidate scope:
- [ ] ...

Forbidden scope:
- ...

Verification target:
- Unit:
- Regression:
- Manual QA:

Done gate:
- ...
```

## CURRENT.md

The only active executable SLICE. If it conflicts with PLAN, DESIGN, TODO, BACKLOG, done, or incidents, stop and reconcile before implementation.

Must include:

- active PART id
- active SLICE id
- status
- goal
- design authority link
- allowed scope
- forbidden scope
- expected output
- verification plan
- UnitTestCore command
- manual QA checklist when needed
- current blockers
- recovery incident link when in recovery

Template:

```md
# CURRENT

Part: part-001
Slice: slice-001
Status: active
Design authority: `.beacon/parts/part-001/DESIGN.md`
TODO source: `.beacon/parts/part-001/TODO.md#part-001-slice-001-short-name`

## Goal

## Allowed Scope
- [ ] ...

## Forbidden Scope
- ...

## Expected Output

## Verification Plan
- UnitTestCore: `.beacon/verification/UnitTestCore.ps1 -Part part-001 -Slice slice-001`
- Manual QA:

## Current Blockers

## Recovery Incident
None
```

## BACKLOG.md

Non-executable backlog. Items here are not permission to implement. Promote backlog work through PLAN, PART DESIGN, PART TODO, and CURRENT before execution.

Recommended item types: `bug`, `design-debt`, `test-gap`, `refactor`, `question`, `idea`, `risk`.

Template:

```md
# Beacon Backlog

## Items

### backlog-001: Short Name

Type: idea
Status: triage

Summary:

Promotion required before execution:
- PLAN update
- PART DESIGN update
- PART TODO SLICE
- CURRENT promotion
```

## done/

Archive completed executable states.

On SLICE completion:

- write a done snapshot of completed CURRENT
- include verification evidence summary
- include manual QA status
- include incident links if recovery happened

On PART completion:

- archive the PART TODO
- write or update `verification-report.md`

## incidents/

Incident records for active work failures, wrong assumptions, unsafe diffs, blocked decisions, or stop-loss events. See `recovery-protocol.md`.

## verification/

Holds `manifest.json` and `UnitTestCore.ps1`. See `verification.md`.
