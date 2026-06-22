# Cost Analysis - Task force 3 · CDO 1

<!-- Doc owner: <Nhóm CDO>
     Status: Skeleton (W11 T6 Pack #1) → Measured actual (W12 T4 Pack #2)
     Word target: 800-1500 từ
     Tier: Light -->

## 1. Cost model per tenant (forecast)

| Component | Unit cost | Tenant avg usage | $/tenant/month |
|---|---|---|---|
| Compute | | | |
| Database | | | |
| Storage | | | |
| Data transfer | | | |
| AI inference | | | |
| Observability | | | |
| **Total / tenant / month** | | | **$...** |

---

## 2. Cost at scale

| Tenant count | Monthly total cost | Avg per-tenant |
|---|---|---|
| 10 | | |
| 50 | | |
| 200 | | |

---

## 3. Cost optimization applied

- **[ ] Spot instances**:
- **[ ] NAT cost optimization**:
- **[ ] S3 lifecycle tiering**:
- **[ ] Bedrock prompt caching**:
- **[ ] Right-sizing nodes**:
- **[ ] Log retention limits**:

---

## 4. Cost vs alternatives (cùng task force)

| Angle | $/tenant/month forecast | Why diff |
|---|---|---|
| Mine: <angle> | $ | |
| Nhóm khác A | $ | |
| Nhóm khác B | $ | |

---

## 5. Measured actual (Pack #2 only - fill in W12)

### 5.1 2-week capstone spend

| Service | Forecast | Actual | Delta |
|---|---|---|---|
| Compute | | | |
| Database | | | |
| Storage | | | |
| AI inference | | | |
| Observability | | | |
| Network | | | |
| **Total** | | | |

### 5.2 Per-tenant actual

| Tenant test | Service mix | $/day | Extrapolate $/month |
|---|---|---|---|
| | | | |

### 5.3 Cost-per-correct-decision (joint with AI eval)

| Metric | Value |
|---|---|
| Total AI calls in capstone | |
| Correct decisions | |
| Total AI cost | |
| **Cost per correct decision** | |

---

## 6. Cost guardrails

- AWS Budget alerts
- Namespace resource quotas
- Bedrock spending caps

---

## 7. Cost recommendations for production

- Reserved capacity
- Savings Plans
- DynamoDB / Aurora serverless options

## Related documents

- `02_infra_design.md`
- `../../ai/docs/03_ai_engine_spec.md`
- `07_test_eval_report.md`
