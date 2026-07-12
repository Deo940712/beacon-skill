param(
    [string]$Root = (Get-Location).Path,
    [string]$Part = "part-001"
)

$ErrorActionPreference = "Stop"

function Write-IfMissing {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
    )

    if (Test-Path -LiteralPath $Path) {
        "exists: $Path"
        return
    }

    $parent = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent | Out-Null
    }

    Set-Content -LiteralPath $Path -Value $Content -Encoding UTF8
    "created: $Path"
}

$beacon = Join-Path $Root ".beacon"
$partDir = Join-Path (Join-Path $beacon "parts") $Part
$donePartDir = Join-Path (Join-Path $beacon "done") $Part
$incidentDir = Join-Path $beacon "incidents"
$verificationDir = Join-Path $beacon "verification"

foreach ($dir in @($beacon, $partDir, $donePartDir, $incidentDir, $verificationDir)) {
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
        "created: $dir"
    } else {
        "exists: $dir"
    }
}

$plan = @"
# Beacon Plan

## Project Goal

## Non-goals

## PARTs

| PART | Status | Goal | Design | TODO |
| --- | --- | --- | --- | --- |
| $Part | planned | TBD | `.beacon/parts/$Part/DESIGN.md` | `.beacon/parts/$Part/TODO.md` |

## Success Criteria

## Global Risks

## Global Verification Strategy
"@

$backlog = @"
# Beacon Backlog

Backlog is non-executable. Promote work through PLAN, PART DESIGN, PART TODO, and CURRENT before implementation.

## Items
"@

$current = @"
# CURRENT

Status: planning-only

No active executable SLICE is promoted yet.
"@

$design = @"
# $Part DESIGN

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
"@

$todo = @"
# $Part TODO

Design authority: `.beacon/parts/$Part/DESIGN.md`

## SLICE Map

### $Part-slice-001: Short Name

Status: planned

Goal:

Outcome:

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
"@

$manifest = @"
{
  "parts": {
    "$Part": {
      "slices": {
        "slice-001": {
          "type": "implementation",
          "commands": [],
          "dependsOn": [],
          "manualQa": []
        }
      }
    }
  }
}
"@

Write-IfMissing -Path (Join-Path $beacon "PLAN.md") -Content $plan
Write-IfMissing -Path (Join-Path $beacon "BACKLOG.md") -Content $backlog
Write-IfMissing -Path (Join-Path $beacon "CURRENT.md") -Content $current
Write-IfMissing -Path (Join-Path $partDir "DESIGN.md") -Content $design
Write-IfMissing -Path (Join-Path $partDir "TODO.md") -Content $todo
Write-IfMissing -Path (Join-Path $verificationDir "manifest.json") -Content $manifest

$sourceRunner = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "UnitTestCore.ps1"
$targetRunner = Join-Path $verificationDir "UnitTestCore.ps1"
if ((Test-Path -LiteralPath $sourceRunner) -and -not (Test-Path -LiteralPath $targetRunner)) {
    Copy-Item -LiteralPath $sourceRunner -Destination $targetRunner
    "created: $targetRunner"
} elseif (Test-Path -LiteralPath $targetRunner) {
    "exists: $targetRunner"
} else {
    "missing bundled runner: $sourceRunner"
}
