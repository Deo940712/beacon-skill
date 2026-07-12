# Collaboration — Multi-Agent / Multi-Person Beacon over Git

This reference extends Beacon V1 for parallel work: several agents or people,
each in their own git branch/worktree, executing different slices of the same
`.beacon/` plan. Single-operator repos may ignore this file entirely — nothing
here changes solo behavior.

## Roles

| Role | Owns | May write |
|---|---|---|
| **Lead** (exactly one: a person or the orchestrating agent) | plan integrity, merges, gates | PLAN.md, every DESIGN.md, BACKLOG triage, claim approvals |
| **Worker** (N agents/people) | one claimed slice at a time | its claimed TODO entry status, its own worktree CURRENT.md, code in claimed scope, its done/ snapshot |

Single-writer rule: **PLAN and DESIGN have one writer (the Lead)**. Workers propose
plan changes via BACKLOG items or audit findings — never by editing PLAN/DESIGN
directly on a worker branch. This is what keeps merges trivial.

## Claiming a slice (the scheduling primitive)

The TODO slice entry is the lock. To claim, a worker (or the Lead assigning) edits
the slice header on the **integration branch** (or via a micro-PR that touches only
that entry) before any code:

```md
### part-004-slice-002: x_sync 轉換器

Status: claimed
Claimed-by: worker-b            # agent name or person
Branch: slice/part-004-002-x-sync
Claimed-at: 2026-07-15
Files-scope: skills/x_sync/**, tests/test_x_sync.py   # exclusive write set
```

Claim rules:

- A slice may be claimed only if `Status: planned` and its PART DESIGN exists.
- **Files-scope is an exclusive write set.** Two simultaneously claimed slices must
  have disjoint Files-scope. If scopes would overlap, the slices are not actually
  parallel — re-slice or serialize them. Shared read is always fine.
- Common-file changes (config.py, shared core modules, pyproject) are NOT parallel-
  safe: route them to a single slice, or the Lead applies them on the integration
  branch between waves.
- A claim older than a agreed staleness window (default: 2 days without a push)
  may be reclaimed by the Lead: reset to `planned`, note the reset in the entry.

## Branch and worktree discipline

```
main (or develop)      ← integration branch; .beacon/ truth lives here
└── slice/part-XXX-YYY-shortname   ← one branch per claimed slice
```

- Branch naming: `slice/part-XXX-YYY-shortname`. One slice = one branch = one
  eventual merge. No shared feature branches across slices.
- Each worker uses a separate worktree/clone. `CURRENT.md` is **worktree-local
  working state**: it is filled from the claimed TODO entry on the worker branch
  and is **reverted to the integration version before merge** (see merge steps).
  CURRENT.md never merges; the durable record is the done/ snapshot.
- Workers never rebase the integration branch; workers rebase their slice branch
  onto latest integration before requesting merge.

## Merge protocol (per slice)

1. Worker: verification green in the worktree (UnitTestCore target + regression).
2. Worker: run the **audit gate** (continuous-loop.md) on the slice branch; log
   findings to KNOWN_ISSUES.md on the branch.
3. Worker: write the done/ snapshot (`done/part-XXX/…-done-current.md` includes
   branch name and audit result), mark the TODO entry `Status: review`.
4. Worker: rebase onto integration, re-run tests, push, open PR / request merge.
5. Lead: check the PR touches only Files-scope (+ its tests + its .beacon entries).
   Out-of-scope diff = reject back to worker (or open an incident if unsafe).
6. Lead: merge. `.beacon/` merge conflicts should not happen by construction:
   PLAN/DESIGN single-writer, TODO entries are per-slice blocks, done/ files are
   uniquely named, CURRENT.md was reverted. A conflict signals a protocol breach —
   stop and reconcile before merging anything else.
7. Lead: after each merge wave, run the **integration audit**: full regression on
   the integration branch + probe the contract boundaries BETWEEN merged slices
   (per-branch audits cannot see cross-slice interactions).
8. Lead: flip TODO entry to `done`, promote/approve next claims.

## Scheduling parallel work (what the Lead optimizes)

- **Parallelize by Files-scope, not by theme.** The dependency question is "do these
  slices write the same files or contracts", not "are they related".
- **Wave planning**: pick the set of `planned` slices with pairwise-disjoint
  Files-scope and satisfied `dependsOn` (verification manifest) — that set is one
  wave. Anything touching shared plumbing runs solo between waves.
- **Contract-first splitting**: when two slices must share a new interface, land a
  tiny solo slice that defines the contract (types/schema/stub + tests) first;
  then the dependents parallelize safely against the frozen contract.
- Keep per-slice size within slice-contract.md norms; parallelism never justifies
  oversized slices.
- Status vocabulary for TODO entries under collaboration:
  `planned → claimed → review → done` (plus `blocked` linking an incident).

## Incidents and audits under collaboration

- Worker-branch audit findings: HIGH severity blocks that branch's merge; the fix
  lands on the same branch before review.
- Integration-audit findings: Lead triages per continuous-loop.md; cross-slice
  design flaws amend DESIGN (Lead) and may re-slice unclaimed work.
- Incidents follow recovery-protocol.md unchanged; the incident file lives on the
  integration branch (Lead commits it) so all workers see it.
- A worker hitting a Hard Stop pauses its branch and reports; other branches
  continue unless the incident's Files-scope overlaps theirs.

## Solo ↔ team switching

The scheme degrades gracefully: a solo operator is simply Lead+Worker in one,
claims are self-assignments, and the integration branch is main. Adopting
collaboration later requires no artifact migration — only starting to fill the
claim fields and enforcing single-writer on PLAN/DESIGN.
