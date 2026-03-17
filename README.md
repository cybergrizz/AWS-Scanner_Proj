# 🛡️ AWS Security Audit Scripts

> A collection of lightweight Bash scripts for auditing common AWS security misconfigurations across IAM, S3, EC2, RDS, ELB, CloudTrail, and GuardDuty.

**Author:** [Kevin Douglas](https://github.com/cybergrizz) · [kdresume.link](https://kdresume.link) · Vienna, VA  
**Focus:** Cloud Security · GRC · AWS

---

## Overview

These scripts are designed to give you a fast, CLI-driven view of your AWS environment's security posture — no third-party tools, no dashboards, just the AWS CLI and Bash. Each individual check targets a specific control and exits with a `0` (pass) or `1` (fail) code. The orchestration layer wraps them into a full multi-account scanner with Slack alerting and per-account reports.

**Key capabilities:**
- Modular per-service checks (drop new scripts into `checks/` to extend)
- Multi-account scanning via STS role assumption
- Automatic category-level failure breakdowns
- Slack notifications with risk level classification (🟢 Low / 🟡 Medium / 🔴 High)
- Per-account scan reports saved to `reports/`

---

## Prerequisites

- **AWS CLI** configured with appropriate credentials (`aws configure`)
- **jq** installed (required for scripts that parse JSON output)
- **IAM permissions** — the scanner assumes a `VulnScanReadOnly` role in each target account; ensure cross-account trust policies are in place
- **Slack Webhook URL** set in `.env` (required for `slack-notify.sh`)

---

## Repository Structure

```
.
├── accounts.txt              # List of AWS account IDs to scan (one per line)
├── assume-role.env           # Environment config for single-account role assumption
├── assume-role.sh            # Standalone STS role assumption helper
├── multi-account-scan.sh     # Orchestrator — loops accounts, runs scanner, sends alerts
├── scanner.sh                # Core scan engine — runs all checks in checks/
├── slack-notify.sh           # Slack webhook notification with risk classification
├── .env                      # Slack webhook URL (not committed)
└── checks/
    ├── cloudtrail-enabled.sh
    ├── cloudtrail-log-encryption.sh
    ├── ec2-port22-open.sh
    ├── ec2-port3389-open.sh
    ├── elb-logging.sh
    ├── elbv2-https.sh
    ├── elbv2-tls-policy.sh
    ├── guardduty-enabled.sh
    ├── iam-inline-policies.sh
    ├── iam-no-mfa.sh
    ├── iam-old-access-keys.sh
    ├── iam-root-mfa.sh
    ├── rds-backups.sh
    ├── rds-encryption.sh
    ├── rds-public.sh
    ├── s3-block-public-access.sh
    ├── s3-bucket-encryption.sh
    └── s3-public-access.sh
```

---

## Orchestration

### How It Works

```
multi-account-scan.sh
  └── reads accounts.txt (one account ID per line)
       └── for each account:
            ├── assumes arn:aws:iam::<ACCOUNT_ID>:role/VulnScanReadOnly via STS
            ├── exports temporary credentials into the shell environment
            ├── runs scanner.sh (which iterates checks/*.sh)
            ├── saves output to reports/scan_<ACCOUNT_ID>.txt
            └── calls slack-notify.sh with pass/fail counts + category breakdown
```

### Multi-Account Scan

Add account IDs to `accounts.txt` (one per line), then run:

```bash
chmod +x multi-account-scan.sh scanner.sh slack-notify.sh
./multi-account-scan.sh
```

The scanner will loop every account, assume the read-only role, run all checks, and fire a Slack alert per account.

### Single-Account / Manual Role Assumption

Use `assume-role.sh` to assume a role in a single account and drop into a scoped shell session:

```bash
# Configure assume-role.env first, then:
source assume-role.sh
./scanner.sh
```

`assume-role.env` should contain:

```bash
ACCOUNT_ID="123456789012"
ROLE_NAME="VulnScanReadOnly"
PROFILE="your-aws-profile"
SESSION_NAME="scanner-session"
```

---

## Slack Notifications

`slack-notify.sh` receives scan results and posts a formatted message to your Slack channel. Risk level is determined by failure count:

| Failures | Risk Level |
|----------|-----------|
| 0 | 🟢 Low Risk |
| 1–5 | 🟡 Medium Risk |
| 6+ | 🔴 High Risk |

**Setup:** Create a `.env` file in the project root:

```bash
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

Example Slack output:
```
🟡 Medium Risk
Account: `103425803255`
Results: ✅ 14 Passed, ❌ 4 Failed, 📋 18 Total
🗂 By Category:
  • IAM: 2 / 4 failed
  • S3: 1 / 3 failed
  • RDS: 1 / 3 failed
🕒 Time: 2025-03-16 18:42 UTC
```

---

## Script Reference

### 🔍 CloudTrail

| Script | What It Checks |
|--------|---------------|
| `cloudtrail-enabled.sh` | Whether any CloudTrail trails exist in the current region |
| `cloudtrail-log-encryption.sh` | Whether all trails have KMS encryption enabled |

---

### 🖥️ EC2

| Script | What It Checks |
|--------|---------------|
| `ec2-port22-open.sh` | Security groups exposing SSH (port 22) to `0.0.0.0/0` |
| `ec2-port3389-open.sh` | Security groups exposing RDP (port 3389) to `0.0.0.0/0` |

---

### ⚖️ ELB / ELBv2

| Script | What It Checks |
|--------|---------------|
| `elb-logging.sh` | Classic load balancers without access logging enabled |
| `elbv2-https.sh` | Application/Network load balancers using unencrypted HTTP listeners |
| `elbv2-tls-policy.sh` | HTTPS listeners using weak TLS policies (TLS 1.0 or 1.1) |

---

### 🕵️ GuardDuty

| Script | What It Checks |
|--------|---------------|
| `guardduty-enabled.sh` | Whether GuardDuty is active in the current region |

---

### 🔑 IAM

| Script | What It Checks |
|--------|---------------|
| `iam-inline-policies.sh` | Users, roles, and groups with inline (non-managed) policies attached |
| `iam-no-mfa.sh` | IAM users without MFA devices registered |
| `iam-old-access-keys.sh` | Access keys older than 90 days |
| `iam-root-mfa.sh` | Whether the root account has MFA enabled |

---

### 🗄️ RDS

| Script | What It Checks |
|--------|---------------|
| `rds-backups.sh` | RDS instances with automated backup retention set to 0 days |
| `rds-encryption.sh` | RDS instances with storage encryption disabled |
| `rds-public.sh` | RDS instances with `PubliclyAccessible` set to `True` |

---

### 🪣 S3

| Script | What It Checks |
|--------|---------------|
| `s3-block-public-access.sh` | Buckets missing the Block Public Access configuration |
| `s3-bucket-encryption.sh` | Buckets without a default encryption policy |
| `s3-public-access.sh` | Buckets with a public bucket policy (`IsPublic: true`) |

---

## Usage

**Full multi-account scan (recommended):**
```bash
./multi-account-scan.sh
```

**Single account scan (no role assumption):**
```bash
./scanner.sh
```

**Run a single check directly:**
```bash
bash checks/iam-root-mfa.sh
```

Each check script prints ✅ or ❌ per resource and exits `0` (all pass) or `1` (at least one finding). `scanner.sh` aggregates results across all checks and prints a summary with per-category breakdowns.

**Legacy — run all checks manually:**

```bash
chmod +x *.sh

# Run a single check
./iam-root-mfa.sh

# Run all checks and log output
for script in *.sh; do
  echo "=== Running $script ==="
  bash "$script"
  echo ""
done
```

Each script prints ✅ or ❌ per resource and exits `0` (all pass) or `1` (at least one finding).

---

## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | All checks passed |
| `1` | One or more findings detected |

---

## Coverage Map

These scripts align to common controls in **CIS AWS Foundations Benchmark** and **NIST SP 800-53**:

| Domain | Controls Covered |
|--------|-----------------|
| IAM | MFA enforcement, access key rotation, inline policy avoidance |
| Data Protection | S3 encryption, RDS encryption, KMS on CloudTrail logs |
| Logging & Monitoring | CloudTrail enabled, ELB access logs, GuardDuty active |
| Network Security | Public RDS exposure, open SSH/RDP to `0.0.0.0/0` |
| In-Transit Encryption | HTTPS listeners, strong TLS policy enforcement |

---

## Notes

- Scripts operate in the **currently configured AWS region**. Run across regions by looping with `AWS_DEFAULT_REGION` set.
- `jq` is required by several scripts (`iam-old-access-keys.sh`, `elbv2-tls-policy.sh`, `assume-role.sh`, `multi-account-scan.sh`).
- The `VulnScanReadOnly` role must exist in every target account with a trust policy allowing your scanner account to assume it.
- Inline policy detection (`iam-inline-policies.sh`) flags all entities — review findings before remediating.
- The `s3-block-public-access.sh` and `s3-bucket-encryption.sh` scripts exit on the first failing bucket. Change `exit 1` to `continue` to scan all buckets.
- `multi-account-scan.sh` has a `sleep 2` between accounts to avoid STS throttling — increase if scanning many accounts.
- Never commit `accounts.txt` with real account IDs or `.env` with your Slack webhook to a public repo. Add both to `.gitignore`.

---

## Author

**Kevin Douglas**  
Cloud Security Engineer · Vienna, VA  
🌐 [kdresume.link](https://kdresume.link) · 🐙 [github.com/cybergrizz](https://github.com/cybergrizz)

---

## License

MIT — use freely, contribute back if you improve it.
