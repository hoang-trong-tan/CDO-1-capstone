# Deployment Contract - Task force 3 (Self-Heal Engine)

<!-- Owner: Nhóm AI TF3
     Signed by: AI Lead + CDO-1 Lead + CDO-2 Lead + Reviewer panel
     Date signed: 2026-06-25 (W11 T5)
     FREEZE - no change without formal change request -->

## Mục đích

Định nghĩa **AI Engine deploy như thế nào** - compute target, scale, secrets, network, rollback. CDO platform cần thông tin này để config infra kết nối và phân bổ capacity.

## Key principle

**Nhóm AI host AI engine ONCE per task force.** 2-3 CDO infra trong task force cùng gọi chung tới một endpoint. Multi-tenant theo header `X-Tenant-Id`.

---

## Compute

| Aspect | Configuration |
|---|---|
| **Target** | <!-- ECS Fargate / Lambda / EKS --> |
| **Cluster** | |
| **Service name** | |
| **Image source** | |
| **CPU per task** | |
| **Memory per task** | |

---

## Scaling

| Aspect | Value |
|---|---|
| **Replicas** | min X, max Y |
| **Autoscale trigger 1** | |
| **Autoscale trigger 2** | |
| **Scale-up cooldown** | |
| **Scale-down cooldown** | |

---

## Secrets

| Secret name | Source |
|---|---|
| | AWS Secrets Manager path |
| | env var |

> Không dùng long-lived access key. Mọi credential qua Secrets Manager rotation.

---

## Networking

| Aspect | Configuration |
|---|---|
| **Subnet type** | <!-- public / private --> |
| **ALB** | <!-- internal only / internet-facing --> |
| **Security group** | |
| **Ingress rules** | |
| **Egress rules** | |
| **DNS** | |

---

## Rollout strategy

| Step | Traffic | Interval |
|---|---|---|
| 1 | X% | Y phút |
| 2 | X% | Y phút |
| 3 | 100% | - |

**Abort criteria**:
- Error rate > X%
- P99 latency > Y ms

---

## Rollback

| Aspect | Value |
|---|---|
| **Primary method** | |
| **Secondary method** | |
| **Target RTO** | < X giây |
| **Auto-trigger** | |

---

## Health check

| Field | Value |
|---|---|
| **Path** | `/health` |
| **Port** | |
| **Interval** | |
| **Healthy threshold** | |
| **Unhealthy threshold** | |

---

## Observability

| Aspect | Configuration |
|---|---|
| **Log destination** | |
| **Metrics** | |
| **Traces** | |

---

## Failure modes & response

| Failure | Detection | Response |
|---|---|---|
| Task crash | | |
| Region outage | | |
| Bedrock throttling | | |
| Memory leak | | |

---

## Open questions

- [ ] Q1: ...
