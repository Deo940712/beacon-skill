# Recovery Protocol V1

Incident V1 is built into the workflow. It is not an optional note-taking step.

## Open an Incident When

- verification fails and the fix is not obvious
- a design assumption is wrong
- the user rejects the outcome
- implementation drifts outside CURRENT scope
- the SLICE is too large or wrongly split
- a risky or unrelated diff appears
- the agent cannot continue without a decision
- a stop-loss decision is needed
- active work becomes unsafe, invalid, unstable, or blocked by a wrong assumption

## File Name

```txt
.beacon/incidents/incident-YYYY-MM-DD-part-001-slice-001-short-name.md
```

## Incident Template

```md
# Incident: short name

Status: open
Part: part-001
Slice: slice-001
Opened: YYYY-MM-DD
Resolved:

## Trigger

## Symptoms

## Evidence

## Touched Files

## Last Known Good State

## Suspected Cause

## Recovery Options

- fix-forward:
- reslice:
- redesign:
- block-for-user:
- abandon:

## Chosen Recovery

## User Approval Required

## Recovery Result

## Follow-up Backlog Items
```

## Recovery Rules

- Stop expanding scope when an incident opens.
- Update `.beacon/CURRENT.md` status to `recovering` or `blocked`.
- Link CURRENT to the incident file.
- Do not use destructive rollback automatically.
- Do not hide failed tests.
- Do not delete or rewrite evidence to make work look successful.
- Do not move incident-only follow-up work into execution unless promoted through DESIGN, TODO, and CURRENT.
- Close the incident only after verification passes or an explicit user decision is recorded.

## Recovery Paths

- **fix-forward**: use when the CURRENT scope remains valid and the fix is narrow.
- **reslice**: use when the slice boundary is wrong; update TODO and promote a replacement CURRENT.
- **redesign**: use when PART assumptions or chosen design are invalid; update DESIGN before further TODO/CURRENT execution.
- **block-for-user**: use when a decision is needed before safe progress.
- **abandon**: use only with explicit user approval; archive the state and plan replacement work.

## Stop-loss Rules

Stop and ask the user before:

- destructive rollback
- abandoning a SLICE
- broad rework outside CURRENT
- discarding user-visible output
- changing PART design direction materially

Rollback may be proposed, but not executed destructively without approval.

## Resolution Checklist

- incident status is `resolved`, `blocked`, or `abandoned`
- CURRENT status reflects the recovery outcome
- verification evidence or user decision is recorded
- follow-up work is placed in BACKLOG only as non-executable triage, or promoted through DESIGN/TODO/CURRENT
- completed/replaced CURRENT is archived under `done/` when appropriate
