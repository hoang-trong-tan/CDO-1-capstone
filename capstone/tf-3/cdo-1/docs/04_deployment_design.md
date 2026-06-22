# Deployment & CI/CD Design - Task force 3 · CDO 1

<!-- Doc owner: <Nhóm CDO>
     Status: Draft (W11 T4) → Final (W11 T6 Pack #1) → Working (W12 T4 Pack #2)
     Word target: 1200-2000 từ
     Tier: Medium -->

## 1. IaC strategy

### 1.1 Tool choice

- **IaC tool**: <!-- Terraform / CDK / CloudFormation --> - Reason: <!-- ... -->
- **State backend**: <!-- S3 + DynamoDB lock / Terraform Cloud -->
- **Modular structure**: <!-- shared modules + environment-specific roots -->

### 1.2 Module structure

```
infra/
├── modules/
│   ├── networking/
│   ├── compute/
│   ├── iam/
│   ├── tenant-provision/
│   └── observability/
├── environments/
│   └── sandbox/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── versions.tf
```

### 1.3 State management

- Remote state per environment.
- State lock via DynamoDB.
- Plan-on-PR + apply-on-merge gate.

---

## 2. CI/CD pipeline

### 2.1 Pipeline stages

```
PR opened ──► Lint ──► Build ──► Scan ──► Plan ──► PR Review ──► Merge ──► Apply ──► Smoke test
```

| Stage | Tool | What it does | Quality gate |
|---|---|---|---|
| Lint | | | |
| Build | | | |
| Test | | | |
| Scan | | | |
| Plan | | | |
| Apply | | | |
| Smoke | | | |

### 2.2 Branch strategy

- `main` = <!-- ý nghĩa của branch này -->
- `feature/*` = feature branches
- PR required for merge to `main` + approval

---

## 3. GitOps

### 3.1 Tool

- <!-- ArgoCD / Flux --> - Reason: <!-- ... -->
- **Repo structure**: <!-- separate "app" repo and "config" repo -->

### 3.2 Sync waves

| Wave | Components | Lý do ordering này |
|---|---|---|
| 0 | | |
| 1 | | |
| 2 | | |
| 3 | | |
| 4 | | |

### 3.3 Drift detection

<!-- Cấu hình auto-sync và phát hiện drift như thế nào? -->

---

## 4. Deployment strategy

### 4.1 Strategy

- **Chosen**: <!-- Canary / Blue-green / Rolling Update --> - Reason: <!-- ... -->
- **Abort criteria**:
  - Error rate > X%
  - P99 latency > Xms
- **Auto-rollback** on abort: <!-- Có hay không? Cơ chế ra sao? -->

### 4.2 Rollback method

- **Primary**: <!-- Git revert (app) / ECS service revert (compute) -->
- **Infra rollback**: <!-- Manual gate, không tự động -->
- **Target RTO**: < X giây

---

## 5. Environment separation

| Env | Purpose | Account | Auto-deploy |
|---|---|---|---|
| Sandbox | | | |
| Staging | | | |
| Prod | | | |

---

## 6. Secrets in pipeline

<!-- CI accesses secrets thế nào? OIDC + IAM, gitleaks scan, block merge nếu phát hiện secret -->

---

## 7. Tenant onboarding deployment

```
1. ...
2. ...
3. ...
```

Total time target: < 30 min.

---

## 8. Observability stack

| Component | Tool | Lý do chọn |
|---|---|---|
| Metrics | | |
| Logs | | |
| Traces | | |
| Dashboards | | |
| Alerts | | |

---

## 9. Open questions

- [ ] Q1: ...

## Related documents

- [`02_infra_design.md`](02_infra_design.md)
- [`03_security_design.md`](03_security_design.md)
- [`08_adrs.md`](08_adrs.md)
