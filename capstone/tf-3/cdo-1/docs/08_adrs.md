# Architecture Decision Records - CDO 1 · Task force 3 (Self-Heal Engine)

<!-- Doc owner: CDO Team TF3
     Status: Ongoing log W11-W12
     Format: 1 ADR per major decision. Append-only - không xóa ADR cũ.
     Target: >= 3 ADR cho Pack #1 (W11) · >= 5 ADR cho Pack #2 (W12)
     Tier: Light -->

---

## ADR-001 - Chọn EKS + Karpenter làm nền tảng compute cho Sandbox

- **Status**: Proposed
- **Date**: 2026-06-22
- **Context**: 
- **Decision**: 
- **Consequence**:
  - ✅ Pro 1
  - ✅ Pro 2
  - ⚠️ Con 1
  - ⚠️ Con 2
- **Alternatives considered**:
  - Option A: ... (rejected because ...)
  - Option B: ... (rejected because ...)

---

## ADR-002 - Dual Execution Path: GitOps (deferred) kết hợp Direct K8s API Patch (urgent)

- **Status**: Accepted
- **Date**: 2026-06-23
- **Context**: 
  Hệ thống cần cơ chế Self-Heal kết hợp 2 yêu cầu mâu thuẫn: (1) phản hồi cực nhanh để cứu Pod khi lỗi OOM/Stuck với latency < 15s, (2) đảm bảo mọi thay đổi được ghi nhận trên Git (Audit Trail) để đạt SOC2 Type II vào tháng 9. GitOps thuần (ArgoCD sync cycle 3 phút) không đáp ứng được latency.
- **Decision**: 
  Chọn Dual Execution Path (Hybrid):
  - **Fast Lane (Direct K8s API Patch):** Tắt Auto-Sync của ArgoCD tạm thời -> Patch/Kill/Rollout/Scale trực tiếp trên cluster K8s trong < 1s. Cứu ứng dụng ngay lập tức.
  - **Slow Lane (GitOps Sync):** Commit cấu hình mới (memory limit, replicas, rollout annotation) lên GitHub -> Force ArgoCD sync -> Reconcile về trạng thái mong muốn. Đảm bảo Git và Cluster đồng bộ.
- **Consequence**:
  - ✅ Pod phục hồi trong 0.028s (OOM) / 0.036s (Restart) / 0.021s (Scale) - đáp ứng SLO < 15s
  - ✅ GitOps sync hoàn tất trong ~2.5s sau Git push (qua ArgoCD Force Sync API) - đáp ứng SLO < 120s
  - ✅ Không Race Condition (ArgoCD bị tạm tắt Sync trước khi Patch, chỉ bật lại sau khi Git commit xong)
  - ⚠️ Phải quản lý tuần tự "Tắt Sync -> Patch -> Commit -> Bật Sync" trong code của Webhook Receiver
  - ⚠️ Rollout Restart (Case 2) không thay đổi Git manifest nên chỉ audit trail, không cần Git commit config change
- **Alternatives considered**:
  - Option A: K8s Native Operator (Go/Kopf chạy 24/7) -> rejected vì chi phí idle cao, phí tổn code state machine cho Rollback/Circuit Breaker phức tạp.
  - Option B: Step Functions Serverless -> rejected vì không có Git integration tự nhiên, Audit trail không mạnh bằng Git history.
- **Evidence**:
  POC chạy trên Minikube ngày 2026-06-23 (file: `poc/run_test.py`):
  ```
  Test 1 (Race Condition verif): Patch khi ArgoCD Sync ON -> ArgoCD revert trong < 1s. Xác nhận tồn tại race.
  Test 2 (Sync Suspension):     Tắt Sync -> Patch -> Git commit -> Bật Sync -> Synced + Healthy. PASS.
  ```
  Metrics đo được:
  | Case | Latency Patch (Fast) | Git Push (Slow) | ArgoCD Sync |
  |------|---------------------|-----------------|-------------|
  | OOMKilled (Memory)  | 0.028s | 2.516s | Synced/Healthy |
  | Stuck Service (Rollout) | 0.036s | 2.540s | Synced/Healthy |
  | Queue Backlog (Scale)   | 0.021s | 2.480s | Synced/Healthy |

---

## ADR-003 - S3 Object Lock (COMPLIANCE mode) + Kinesis Firehose là nguồn kiểm toán bất biến duy nhất

- **Status**: Proposed
- **Date**: 2026-06-22
- **Context**: 
- **Decision**: 
- **Consequence**:
  - ✅ Pro 1
  - ✅ Pro 2
  - ⚠️ Con 1
  - ⚠️ Con 2
- **Alternatives considered**:
  - Option A: ... (rejected because ...)
  - Option B: ... (rejected because ...)

---

## ADR-004 - DynamoDB State Machine với Conditional Write Lock và Auto-Expiry TTL cho Incident Tracking

- **Status**: Proposed
- **Date**: 2026-06-22
- **Context**: 
- **Decision**: 
- **Consequence**:
  - ✅ Pro 1
  - ✅ Pro 2
  - ⚠️ Con 1
  - ⚠️ Con 2
- **Alternatives considered**:
  - Option A: ... (rejected because ...)
  - Option B: ... (rejected because ...)

---

## ADR-005 - Bổ sung Pattern thứ 5 (Designed-only): Disk Space Exceeded trên EKS Node

- **Status**: Proposed
- **Date**: 2026-06-22
- **Context**: 
- **Decision**: 
- **Consequence**:
  - ✅ Pro 1
  - ✅ Pro 2
  - ⚠️ Con 1
  - ⚠️ Con 2
- **Alternatives considered**:
  - Option A: ... (rejected because ...)
  - Option B: ... (rejected because ...)
