# Secured Multi-Environment AWS Deployment Pipeline

A Terraform + GitHub Actions pipeline that provisions AWS infrastructure across
separate **staging** and **production** environments, with a manual approval
gate protecting production and shared remote state keeping local and CI/CD
runs in sync.

## What this project demonstrates

- Infrastructure as Code with **Terraform** (resources, variables, remote state)
- **CI/CD** with GitHub Actions, triggered by branch pushes
- A **promotion workflow**: feature branch → PR into `staging` → test → PR into
  `main` → manual approval → production
- **Least-privilege IAM**: separate AWS users scoped to only what each task needs
- Debugging real infrastructure and tooling failures, not just following a
  tutorial end to end

## Architecture

```
Feature branch
     │  (PR)
     ▼
  staging branch ──push──▶ GitHub Actions (staging.yml) ──▶ staging S3 bucket
     │  (PR)
     ▼
   main branch ───push──▶ GitHub Actions (production.yml)
                              │
                              ▼
                     ⏸ waits for manual approval
                       (GitHub Environment: production)
                              │
                              ▼
                     production S3 bucket
```

Both workflows read and write to the same **Terraform state**, stored in a
dedicated S3 bucket (`rob-terraform-state-2026`), so local runs and CI runs
always see a consistent picture of what actually exists in AWS.

## Key decisions, and why

**Separate `.tfvars` per environment** (`staging.tfvars`, `production.tfvars`)
Same Terraform code, different values per environment, instead of duplicating
`.tf` files. Keeps staging and production from drifting apart in structure.

**Manual approval gate on production**
Configured via a GitHub Environment (`production`) with a required reviewer.
Staging deploys automatically on merge; production pauses and waits for an
explicit human approval before `terraform apply` runs. This mirrors a basic
change-management control — nothing reaches production without review.

**Remote state in S3**
Originally, Terraform state lived only on whichever machine ran `apply` —
which meant local runs and GitHub Actions runs had no shared memory of what
had been created. Moved state into a dedicated, versioned S3 bucket so every
environment (laptop or CI) reads/writes the same state.

**Least-privilege IAM**
Two separate IAM users: one read-only (`robreadonly`) for inspecting
resources, one scoped to creation tasks (`robcreateaccess`) for actually
provisioning infrastructure. Avoids a single broad-permission user for
everything.

**`.gitignore` from day one (lesson learned)**
An early commit included the local `.terraform/` provider plugin directory
(648MB) before `.gitignore` was in place, which blocked pushes to GitHub
until the Git history was reset. Current setup excludes `.terraform/`,
state files, and `terraform.tfvars` from version control.

## Real problems hit and fixed along the way

- IAM `AccessDenied` errors on EC2 and S3 actions, traced to using a
  read-only user for write operations
- A misattached IAM policy (wrong AWS-managed policy with a similar name)
  found by reading the actual policy JSON, not just trusting the name
- A 648MB file blocking a GitHub push, due to committing `.terraform/`
  before `.gitignore` existed — fixed by resetting Git history
- AWS credential mismatches between local CLI profiles, VS Code's selected
  Python interpreter, and GitHub Actions secrets
- `terraform init` failing against the new S3 backend due to missing
  credentials on that specific step (separate from the `apply` step)
- A local `terraform plan` nearly destroying a real resource because the
  `-var-file` flag was omitted and Terraform silently fell back to a
  stale default value

## Tech stack

Terraform · AWS (S3, IAM) · GitHub Actions · Python (boto3, prior practice) · Git

## Possible next steps

- CloudTrail logging and GuardDuty alerts for the security layer
- Secrets Manager instead of plain GitHub Secrets for application-level secrets
- Kubernetes, if extending toward a full platform/DevOps scope
- Automated `terraform plan` output posted as a PR comment for easier review
