# Verification

Every SLICE must have a verification target before implementation. UnitTestCore V1 is a lightweight runner, not a replacement for project tests or CI.

## Locations

```txt
.beacon/verification/manifest.json
.beacon/verification/UnitTestCore.ps1
```

## Manifest Shape

```json
{
  "parts": {
    "part-001": {
      "slices": {
        "slice-001": {
          "type": "implementation",
          "commands": [
            "pytest tests/test_feature_a.py -q"
          ],
          "dependsOn": [],
          "manualQa": [
            "Check feature A visible behavior."
          ]
        },
        "slice-002": {
          "type": "design",
          "commands": [],
          "dependsOn": [
            "slice-001"
          ],
          "manualQa": [
            "Review DESIGN.md and TODO.md updates."
          ]
        }
      }
    }
  }
}
```

## Runner Modes

```powershell
.beacon/verification/UnitTestCore.ps1 -Part part-001
.beacon/verification/UnitTestCore.ps1 -Part part-001 -Slice slice-001
.beacon/verification/UnitTestCore.ps1 -Part part-001 -Slice slice-002 -IncludeDependencies
.beacon/verification/UnitTestCore.ps1 -All
```

Behavior:

- default slice mode runs only the selected SLICE commands
- `-IncludeDependencies` runs declared dependency SLICE commands first
- PART mode runs all SLICE commands for that PART
- ALL mode runs every PART in manifest order
- manual QA is reported, not executed
- missing commands for non-design slices are warnings by default and failures in strict mode
- the runner must not invent commands

## Verification Target Rules

Each SLICE must state:

- automatic commands when available
- manual QA when needed
- when verification cannot be automated
- dependencies on previous SLICEs
- whether full PART verification is required

Design-only work may use a design review gate instead of automated commands, but must still name the review target and expected evidence.

## Manual QA Reporting

Manual QA must be listed separately from automated command results.

Allowed statuses:

- `not-run`
- `passed`
- `failed`
- `blocked`

Do not claim manual QA was executed unless a human or explicit browser/test interaction actually performed it. UnitTestCore only reports manual QA items.

## Evidence Summary Template

```md
## Verification Evidence

UnitTestCore command:

Automated commands:
- command:
- result:

Manual QA:
- item:
- status:
- evidence:

Incidents:
- none
```
