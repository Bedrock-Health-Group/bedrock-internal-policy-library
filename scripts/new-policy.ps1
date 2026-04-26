param(
    [Parameter(Mandatory = $true)]
    [string]$Title,

    [Parameter(Mandatory = $true)]
    [string]$PolicyId,

    [Parameter(Mandatory = $true)]
    [ValidateSet(
        "governance",
        "privacy-security",
        "compliance-program",
        "healthcare-compliance",
        "operations",
        "finance-administration",
        "human-resources",
        "vendor-management",
        "training-acknowledgements"
    )]
    [string]$Category,

    [Parameter(Mandatory = $true)]
    [string]$Owner,

    [string]$Status = "Draft",

    [string]$ApprovedBy = "Governance & Compliance",

    [string]$AppliesTo = "Covered individuals and entities",

    [string]$ConfidentialityLevel = "Publicly Accessible Policy",

    [string]$Version = "1.0",

    [datetime]$EffectiveDate = (Get-Date),

    [int]$ReviewCycleMonths = 12
)

function ConvertTo-Slug {
    param([string]$Text)

    $slug = $Text.ToLowerInvariant()
    $slug = $slug -replace "&", "and"
    $slug = $slug -replace "[^a-z0-9]+", "-"
    $slug = $slug.Trim("-")
    return $slug
}

$slug = ConvertTo-Slug -Text $Title
$folder = Join-Path "docs" $Category
$filePath = Join-Path $folder "$slug.md"

$effectiveDateText = $EffectiveDate.ToString("yyyy-MM-dd")
$nextReviewDateText = $EffectiveDate.AddMonths($ReviewCycleMonths).ToString("yyyy-MM-dd")

if (!(Test-Path $folder)) {
    New-Item -ItemType Directory -Force -Path $folder | Out-Null
}

if (Test-Path $filePath) {
    Write-Error "Policy file already exists: $filePath"
    exit 1
}

$content = @"
---
title: "$Title"
policy_id: "$PolicyId"
version: "$Version"
status: "$Status"
effective_date: "$effectiveDateText"
last_reviewed: "$effectiveDateText"
next_review_due: "$nextReviewDateText"
policy_owner: "$Owner"
approved_by: "$ApprovedBy"
approval_date: "$effectiveDateText"
applies_to: "$AppliesTo"
confidentiality_level: "$ConfidentialityLevel"
---

# $Title

## Document Control

| Field | Detail |
|---|---|
| **Policy Title** | $Title |
| **Policy ID** | $PolicyId |
| **Version** | $Version |
| **Status** | $Status |
| **Effective Date** | $effectiveDateText |
| **Last Reviewed** | $effectiveDateText |
| **Next Review Due** | $nextReviewDateText |
| **Review Cycle** | Annual |
| **Policy Owner** | $Owner |
| **Approved By** | $ApprovedBy |
| **Applies To** | $AppliesTo |
| **Confidentiality Level** | $ConfidentialityLevel |

Printed, downloaded, or PDF copies should be verified against the live Bedrock Health Group policy library before being relied upon.

---

## 1. Purpose

Describe the purpose of this policy.

## 2. Scope

Describe who and what this policy applies to.

## 3. Policy Statement

State the main policy requirements.

## 4. Definitions

| Term | Definition |
|---|---|
| **Term** | Definition. |

## 5. Roles and Responsibilities

| Role | Responsibility |
|---|---|
| **Policy Owner** | Maintains the policy and review cycle. |
| **Covered Individuals** | Follow the requirements of this policy. |

## 6. Procedure

Describe the required process, steps, or operating requirements.

## 7. Reporting and Escalation

Describe how questions, exceptions, violations, or concerns should be reported or escalated.

## 8. Documentation and Recordkeeping

Describe any required records, retention expectations, or documentation requirements.

## 9. Training and Communication

Describe any training, acknowledgement, or communication requirements.

## 10. Enforcement

Describe consequences for failure to follow this policy, where applicable.

## 11. Exceptions

Describe how exceptions may be requested, reviewed, approved, documented, and monitored.

## 12. Related Policies and Documents

- Related policy or document.

## 13. Revision History

| Version | Date | Summary of Change | Reviewed By | Approved By |
|---|---:|---|---|---|
| $Version | $effectiveDateText | Initial policy draft created. | $Owner | $ApprovedBy |

---

## Approval and Publication Record

Approval evidence, review history, and publication history are maintained through Bedrock Health Group's controlled GitHub review workflow, board records, and applicable acknowledgement records.

This policy page does not serve as an individual signature or acknowledgement form.

Where individual acknowledgement is required, Bedrock Health Group may maintain separate acknowledgement records through a designated acknowledgement process.

| Field | Detail |
|---|---|
| **Approval Method** | GitHub Pull Request Review / Board Record / Written Consent, as applicable |
| **Approving Authority** | $ApprovedBy |
| **Approval Evidence Location** | GitHub pull request review history and related governance records |
| **Publication Method** | MkDocs / GitHub Pages deployment |
| **Publication Trigger** | Merge to main branch |
| **Revision Tracking** | Git commit history and policy revision history |

## Source Record

This Markdown policy was created using the Bedrock Health Group policy generator and standard policy template.

| Source Field | Detail |
|---|---|
| **Generated By** | scripts/new-policy.ps1 |
| **Policy Area** | $Category |
| **Source Classification** | $ConfidentialityLevel |
"@

[System.IO.File]::WriteAllText((Resolve-Path ".").Path + "\$filePath", $content, (New-Object System.Text.UTF8Encoding $false))

Write-Host ""
Write-Host "Created policy file:" -ForegroundColor Green
Write-Host $filePath
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Edit the generated policy body."
Write-Host "2. Update docs/policy-index.md."
Write-Host "3. Update mkdocs.yml navigation if the policy should appear in the public site menu."
Write-Host "4. Commit, push, and open a pull request."
