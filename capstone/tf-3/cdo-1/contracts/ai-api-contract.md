# AI API Contract - Task force 3 (Self-Heal Engine)

<!-- Owner: Nhóm AI TF3
     Signed by: AI Lead + CDO-1 Lead + CDO-2 Lead + Reviewer panel
     Date signed: 2026-06-25 (W11 T5)
     🔒 FREEZE - no change without formal change request -->

## Mục đích

Định nghĩa **API endpoints** mà Nhóm AI expose, Nhóm CDO consume cho Self-Heal Engine.

## Versioning

- **Current version**: `v1.0` (in path `/v1/`)
- **Breaking changes** -> new version path `/v2/`
- **Non-breaking** -> minor bump, no path change

## Authentication

- **Inter-service**: AWS IAM SigV4
- **Cross-account**: STS assume-role với session tag `tenant_id`
- **Audit**: every request/response logged

## Rate limiting

- **Per tenant**: X requests/minute
- **Global API**: Y requests/minute
- **Response on hit**: `429` với header `Retry-After: <seconds>`

---

## Endpoint 1: `POST /v1/detect`

**Mục đích**: Nhận diện anomaly từ telemetry signals do CDO đẩy lên.

### Request headers

| Header | Type | Required | Description |
|---|---|---|---|
| `X-Tenant-Id` | UUID v4 | ✓ | Tenant identifier |
| `Authorization` | IAM SigV4 | ✓ | AWS SigV4 auth header |
| `X-Correlation-Id` | UUID v4 | ✓ | Trace correlation ID |

### Request body

| Field | Type | Required | Description |
|---|---|---|---|
| `signal_name` | string | ✓ | `pod_oom_event` / `service_unhealthy` / `queue_backlog` |
| `alert_payload` | object | ✓ | Chi tiết payload alert |

**Request example**:

```json
{
  "signal_name": "pod_oom_event",
  "alert_payload": {
    "ts": "2026-06-25T10:30:00Z",
    "tenant_id": "tnt-abc123",
    "exit_code": 137
  }
}
```

### Response body

| Field | Type | Description |
|---|---|---|
| `anomaly` | bool | True nếu detect anomaly |
| `severity` | string | `info` / `warning` / `critical` |
| `runbook_id` | string | ID runbook khớp |
| `confidence` | float 0.0-1.0 | Model confidence |
| `reasoning` | string | Human-readable rationale |

---

## Endpoint 2: `POST /v1/decide`

**Mục đích**: Quyết định hành động vá lỗi (Action Plan) dựa trên runbook đã khớp.

### Request body

| Field | Type | Required | Description |
|---|---|---|---|
| `runbook_id` | string | ✓ | ID runbook |
| `correlation_id` | UUID v4 | ✓ | Tracing ID |
| `dry_run_mode` | bool | ✓ | Chạy giả lập nếu true |
| `tenant_id` | UUID v4 | ✓ | ID tenant |

### Response body

| Field | Type | Description |
|---|---|---|
| `suggested_action` | enum | `INCREASE_MEMORY` / `RESTART_PODS` / `SCALE_WORKERS` / `ROTATE_SECRET` / `ESCALATE` |
| `action_params` | object | Các tham số thực thi |
| `blast_radius_limit` | object | Giới hạn vùng ảnh hưởng |
| `confidence` | float 0.0-1.0 | Độ tin cậy quyết định |
| `audit_id` | UUID v4 | Audit key reference |

---

## Endpoint 3: `POST /v1/verify`

**Mục đích**: Xác thực trạng thái hệ thống sau khi CDO đã thực thi hành động vá lỗi.

### Request body

| Field | Type | Required | Description |
|---|---|---|---|
| `correlation_id` | UUID v4 | ✓ | ID sự cố |
| `action_taken` | object | ✓ | Hành động CDO đã thực hiện |
| `post_state_window` | array | ✓ | Metrics/signals sau vá lỗi |

### Response body

| Field | Type | Description |
|---|---|---|
| `success` | bool | True nếu hệ thống ổn định |
| `regression_detected` | bool | Có lỗi regression không |
| `next_action` | enum | `DONE` / `ROLLBACK` / `ESCALATE` |
| `reasoning` | string | Giải thích kết quả |

---

## SLA

| Metric | Target | Justification |
|---|---|---|
| P99 latency (`/v1/detect`) | < X ms | |
| P99 latency (`/v1/decide`) | < Y ms | |
| P99 latency (`/v1/verify`) | < Z ms | |
| API Throughput | X RPS | |
| Availability | >= 99.5% | |

---

## Error codes & CDO Actions

| HTTP Status | Meaning | CDO Action |
|---|---|---|
| `400` | Invalid schema | Fix client, no retry |
| `401` | Auth failed | Refresh credential, retry once |
| `429` | Rate-limit | Exponential backoff |
| `503` | AI sập | Fallback to rule-based or Escalate |

---

## Open questions

- [ ] Q1: ...
