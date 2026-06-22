# Telemetry Contract - Task force 3 (Self-Heal Engine)

<!-- Owner: Nhóm AI TF3
     Signed by: AI Lead + CDO-1 Lead + CDO-2 Lead + Reviewer panel
     Date signed: 2026-06-25 (W11 T5)
     FREEZE - no change without formal change request -->

## Mục đích

Định nghĩa **signals nào CDO emit từ EKS Sandbox** -> AI engine consume.

## Versioning

- **Current version**: `v1.0`
- **Evolution**: backward-compatible additions only. Breaking change -> new contract version + migration window.
- **Change request process**: raise trong WhatsApp group task force -> task force meeting discuss -> bump version + notify all parties.

---

## Signals required

### Signal 1: `pod_oom_event` - Pod bị OOMKilled (exit code 137)

| Attribute | Value |
|---|---|
| **Type** | event |
| **Labels** | |
| **Frequency** | on-event |
| **Emit point** | |
| **Retention** | |
| **Used for** | OOMKilled pattern detection |
| **Emit SLA** | p99 < Xs |
| **Volume SLA** | X events/min |

**Schema example**:

```json
{
  "ts": "2026-06-25T10:30:00Z",
  "tenant_id": "",
  "namespace": "",
  "pod_name": "",
  "exit_code": 137,
  "correlation_id": ""
}
```

---

### Signal 2: `service_unhealthy` - Service health check failure

| Attribute | Value |
|---|---|
| **Type** | event |
| **Labels** | |
| **Frequency** | on-event |
| **Emit point** | |
| **Retention** | |
| **Used for** | Service Stuck pattern detection |
| **Emit SLA** | p99 < Xs |
| **Volume SLA** | X events/min |

**Schema example**:

```json
{
  "ts": "2026-06-25T10:30:00Z",
  "tenant_id": "",
  "namespace": "",
  "service_name": "",
  "error_rate_pct": 0.0,
  "correlation_id": ""
}
```

---

### Signal 3: `queue_backlog` - Queue depth exceeded threshold

| Attribute | Value |
|---|---|
| **Type** | gauge |
| **Labels** | |
| **Frequency** | every Xs |
| **Emit point** | |
| **Retention** | |
| **Used for** | Queue Backlog pattern detection |
| **Emit SLA** | p99 < Xs |
| **Volume SLA** | X events/min |

**Schema example**:

```json
{
  "ts": "2026-06-25T10:30:00Z",
  "tenant_id": "",
  "queue_name": "",
  "messages_visible": 0,
  "correlation_id": ""
}
```

---

## Cross-cutting requirements

- **Tenant scoping**: mọi signal **bắt buộc** có `tenant_id` field.
- **Correlation tracing**: mọi signal **bắt buộc** có `correlation_id` (UUID v4).
- **Time precision**: timestamp RFC3339 UTC, millisecond precision.
- **Schema validation**: AI ingestion layer validate schema; reject malformed -> dead-letter queue.
- **PII**: KHÔNG được chứa PII trong signal value hoặc labels.

---

## Open questions

- [ ] Q1: Signal nào cần exactly-once delivery so với at-least-once OK?
- [ ] Q2: ...
