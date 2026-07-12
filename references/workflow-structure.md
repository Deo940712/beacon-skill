# Workflow Structure

Use this reference when the agent needs the Beacon process shape. It is the
runtime rule card, not the pretty architecture document.

## Core Flow

```mermaid
flowchart LR
    Plan["PLAN.md<br/>project map"] --> Design["PART DESIGN.md<br/>design authority"]
    Design --> Todo["PART TODO.md<br/>slice map"]
    Todo --> Current["CURRENT.md<br/>one executable slice"]
    Current --> Work["Implement<br/>allowed scope only"]
    Work --> Verify["UnitTestCore<br/>manual QA report"]
    Verify --> Done["done/<br/>evidence archive"]
    Done --> Audit["AUDIT gate<br/>continuous-loop.md"]
    Audit -->|clean / minor| Todo
    Audit -.->|design flaw| Design
    Verify -.->|failure or drift| Incident["incidents/<br/>recovery record"]
    Audit -.->|hard stop| Incident
    Incident -.->|fix-forward| Current
    Incident -.->|reslice| Todo
    Incident -.->|redesign| Design
```

## Resume Rules

- Missing `.beacon/`: initialize planning-only state before coding.
- `CURRENT.md` status `planning-only`: update only PLAN, DESIGN, or TODO.
- `CURRENT.md` status `active`: read active DESIGN and TODO, then execute only
  CURRENT scope.
- `CURRENT.md` status `recovering` or `blocked`: read the linked incident first.
- `CURRENT.md` looks finished (scope done, verification green) but no done/
  snapshot or audit record exists: the previous session stopped mid-loop.
  Resume at Archive → Audit, not at implementation, and not by asking the user
  what to do next.
- Missing content is a user question only when product or design intent cannot
  be inferred.

## Closure Rules

- Finish a slice by verifying, **running the audit gate (continuous-loop.md)**,
  archiving completed CURRENT plus evidence, marking the TODO slice done, then
  promoting the next ready slice if one exists.
- Finish a PART by keeping `parts/part-XXX/TODO.md` as a compact final index and
  archiving the full completed TODO snapshot under `done/part-XXX/`.
- Cross-slice handoff does not need `HANDOFF.md` in V1. Use TODO status, done
  evidence, and the next CURRENT.
- Multi-agent work uses separate worktrees or branches with claimed slices and
  disjoint Files-scope — full protocol in `collaboration.md`. Do not represent
  multiple active slices in one `.beacon/CURRENT.md`.
