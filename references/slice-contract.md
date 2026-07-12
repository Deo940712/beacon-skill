# Slice Contract

A SLICE is the smallest independently verifiable unit of Beacon execution. `TODO.md` maps slices; `CURRENT.md` expands exactly one selected slice.

## Compact TODO Contract

```md
### part-001-slice-001: Short Name

Status: planned            # planned | claimed | review | done | blocked
                           # (claimed/review only under collaboration.md)

Goal:

Outcome:

Candidate scope:
- [ ] ...

Forbidden scope:
- ...

Files-scope:               # optional solo; REQUIRED under collaboration —
- ...                      # exclusive write set for parallel claim safety

Verification target:
- Unit:
- Regression:
- Manual QA:

Done gate:
- ...
```

## Required Gates

Before implementation, a SLICE must have:

- one observable outcome
- allowed and forbidden scope
- verification target
- done gate
- design authority link through its PART DESIGN

If any gate is missing, stop and fix the artifact before coding.

## Right Size

A SLICE is the right size when it:

- delivers one observable outcome
- has one dominant design or behavior risk
- has a clear done gate
- can be verified independently
- can reasonably fit in one agent work session
- usually has 3 to 8 candidate scope bullets
- usually has 1 to 3 focused verification commands
- usually keeps its TODO entry under 60 to 100 lines
- usually keeps its CURRENT expansion under 150 to 250 lines

## Split Rules

Split a SLICE when:

- the goal contains multiple independent outcomes
- scope crosses several independent surfaces such as UI, API, persistence, runtime, migration, and documentation
- more than one major design decision remains unresolved
- verification requires unrelated test suites or unrelated manual QA scenarios
- candidate scope exceeds about 8 to 10 bullets
- implementation starts requiring repeated "also" work
- recovery would be hard to explain as one failure

## Merge Rules

Merge a SLICE when:

- it has no independent done gate
- it cannot be tested or QAed separately
- it is only mechanical setup for the next SLICE
- it shares the same verification target as an adjacent SLICE
- its CURRENT would be too thin to justify the context overhead

## Design-only SLICEs

Design-only SLICEs are allowed when the done gate is reviewable:

- accepted design document
- resolved open questions
- updated PART TODO
- explicit implementation slice promotion

Design-only completion does not authorize implementation. Implementation still needs a promoted CURRENT slice.

## Promotion to CURRENT

Promote exactly one ready SLICE by expanding it into `.beacon/CURRENT.md` with:

- active PART and SLICE id
- status `active`
- design authority link
- allowed scope copied and clarified from TODO
- forbidden scope copied and clarified from TODO
- expected output
- verification plan and UnitTestCore command
- manual QA checklist when needed
- blockers or recovery incident link

Never promote from BACKLOG directly.
