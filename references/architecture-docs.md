# Architecture Documents — Writing Standard

This reference defines how to write the project-level design documents that sit
ABOVE `.beacon/` (the plan executes them; they outrank everything but the user).
Use it when creating or amending ARCHITECTURE.md, interface specs, or subsystem
technical specs.

## Document hierarchy and authority

```
ARCHITECTURE.md            # system design authority (one per repo)
<TOPIC>.md / INTERFACES.md # per-domain design authority (optional, linked)
docs/<subsystem>-{zh,en}.md# implementation-level tech spec (optional, bilingual)
.beacon/PLAN.md            # executes the architecture; mirrors its build order
.beacon/parts/*/DESIGN.md  # per-part authority; cites architecture sections, never contradicts
```

Rules:

- Exactly one design authority per topic. Other files link to it; never duplicate
  normative content (a copied table WILL drift). Beacon artifacts cite sections
  (e.g. "DDL authority: ARCHITECTURE.md §5.1") instead of restating them.
- Amendments happen in place with a one-line reason. Superseded decisions are
  struck through (~~old~~ → new), not deleted — the reasoning trail is the value.
- Every open decision lives in ONE list (architecture "Open Decisions" section)
  and each item maps to a BACKLOG entry. Resolve = strike through + record where.

## Required sections (system architecture doc)

1. **Goals / Non-goals** — non-goals are load-bearing; list rejected approaches
   with the reason (paper, probe result, or measured cost)
2. **System diagram** — one mermaid flowchart of components + data flow
3. **Component contracts** — for each moving part: responsibility, inputs,
   outputs, who may write what (single-writer rules made explicit)
4. **Data model** — full DDL / schemas with types, constraints, indexes, and
   NULL semantics as comments; field tables for document stores (type, required,
   meaning per field)
5. **Key flows** — one mermaid sequenceDiagram per critical path (happy path +
   the failure branches that matter: rejection, timeout, retry)
6. **Reliability table** — risk → concrete mechanism (not "we handle errors")
7. **Directory structure** — annotated tree
8. **Build order** — phased with verifiable gates; mirrored by .beacon/PLAN.md
9. **Open decisions** — each with current leaning and what blocks on it
10. **Design rationale table** — decision → source (paper/repo/probe), so future
    sessions don't relitigate settled questions

## Diagram rules

- mermaid only (renders on GitHub/Obsidian); flowchart for structure,
  sequenceDiagram for flows, stateDiagram-v2 for lifecycles
- Every diagram must match the prose and the schema — an audit finding against a
  diagram is a real finding; fix the diagram or fix the design
- Label edges with the actual payload/action, not "data"

## Probe-verified facts (the hard rule)

Design assumptions about platform behavior (library APIs, tokenizers, locking,
encoding, OS quirks) must be **executed, not assumed**, before they enter the doc:

1. Write a throwaway probe script that exercises the exact behavior
2. Record findings in the design doc as a "probe findings" table:
   `| # | finding | design consequence |`
3. Mark the table "verified <date>, <platform> — do not 'fix' by intuition"
4. Delete the probe; the table is the durable artifact

Historical motivation: 4 of 9 probed assumptions in one design were wrong
(extension loading per-connection, no INSERT OR REPLACE support, INTEGER-only
rowids, CJK never matching the default FTS tokenizer). Unprobed, each would have
become a runtime crash or a silently broken feature.

## Implementation-level tech specs (docs/<subsystem>-{zh,en}.md)

Write these when a subsystem has enough non-obvious mechanics that DESIGN.md
would bloat (file formats, invariants, API tables, failure/recovery matrices).

- Bilingual pair when the team/user is non-English: `-zh.md` + `-en.md`,
  content-identical, cross-linked in the header; same structure so diffs align
- Must include: overview diagram, per-module API tables (function → behavior),
  **invariants** (numbered, testable statements), failure modes → recovery table,
  and honest **known limitations** (what was deliberately not solved and why)
- The spec cites the architecture doc; the DESIGN cites the spec; tests cite the
  invariants (an invariant without a test is a wish)

## Consistency audit (run when docs change)

- Cross-references resolve (section numbers, file paths, backlog ids)
- Schema appears in exactly one place; all citations point there
- Diagrams ↔ prose ↔ DDL agree (state names, component names, field names)
- Every open decision has an owner artifact; every resolved one is struck through
- Executable claims (commands, DDL) actually run — paste into a shell/sqlite
  before committing the doc
