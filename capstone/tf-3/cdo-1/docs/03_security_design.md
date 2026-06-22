# Security Design - Task force 3 · CDO 1

<!-- Doc owner: <Nhóm CDO>
     Status: Draft (W11 T4) → Final (W11 T6) → Refined (W12 T4)
     Word target: 1200-2000 từ
     Scope: DevOps-level security (network, IAM, secrets, encryption, audit, K8s if applicable).
     Tier: Medium -->

## 1. Network Security

### 1.1 Network Diagram

<!-- Mermaid diagram thể hiện VPC layout, subnet, SG, ALB, NAT, internet gateway -->

### 1.2 Security Groups

| SG name | Inbound | Outbound | Attached to |
|---|---|---|---|
| | | | |

### 1.3 Network ACL / VPC Endpoint

- VPC endpoint cho Bedrock runtime:
- VPC endpoint cho Secrets Manager:
- VPC endpoint cho S3 (audit storage):

---

## 2. IAM & Access Control

### 2.1 Service Roles

| Role | Used by | Permissions (least-privilege) |
|---|---|---|
| | | |

### 2.2 K8s RBAC

| Role | Subject | Verbs | Resources | Namespace scope |
|---|---|---|---|---|
| | | | | |

### 2.3 Cross-account Access

<!-- Nếu task force account khác với platform account, ghi rõ assume role pattern -->

---

## 3. Secrets Management

### 3.1 Secrets Inventory

| Secret | Storage | Rotation | Accessed by |
|---|---|---|---|
| | | | |

### 3.2 Inject Pattern

<!-- ECS task definition? Kubernetes External Secrets Operator? Env var via Init container? -->

### 3.3 Anti-leak Controls

- Secrets KHÔNG commit Git.
- Container image không bake credential.
- Application log redact pattern.

---

## 4. Encryption

### 4.1 At Rest

| Data | Storage | KMS key | Notes |
|---|---|---|---|
| | | | |

### 4.2 In Transit

- ALB listener TLS setup.
- Internal service-to-service communication encryption.
- AWS services invocation encryption.

### 4.3 Key Management

- CMK rotation settings.
- Key policy.
- KMS audit.

---

## 5. Audit Logging

### 5.1 What to Log

<!-- AI engine decision fields, Infrastructure change tracking, K8s API mutation, app errors -->

### 5.2 Storage + Retention

| Log type | Storage | Retention | Query interface |
|---|---|---|---|
| | | | |

### 5.3 PII Handling (basic)

- Schema whitelist.
- Redaction at ingest.

---

## 6. Container & K8s Security (chỉ áp dụng nếu CDO chọn K8s/EKS angle)

- Image scan rules.
- Image signing.
- Pod Security Standard profiles.
- NetworkPolicies.
- IRSA (IAM Roles for Service Accounts).

---

## 7. Compliance Touchpoints

| Standard | Relevant controls (capstone scope) |
|---|---|
| SOC2 Type II | |
| GDPR | |

---

## 8. Open Questions

- [ ] Q1: ...
- [ ] Q2: ...

## Related documents

- `02_infra_design.md`
- `04_deployment_design.md`
- `08_adrs.md`
