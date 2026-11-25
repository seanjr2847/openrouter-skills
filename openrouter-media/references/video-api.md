# Video API reference (OpenRouter)

Endpoint: `POST https://openrouter.ai/api/v1/videos` (asynchronous)
Discovery: `GET https://openrouter.ai/api/v1/videos/models` (public)

## Flow

1. Submit -> `{ "id": "...", "polling_url": "...", "status": "pending" }`
2. Poll `GET /api/v1/videos/{id}` until `completed`, `failed`, `cancelled`, `expired`
3. Download `GET /api/v1/videos/{id}/content?index=0` **with the Authorization header**
   (`unsigned_urls` are not presigned). `urls` (when present) are signed and work
   without a key until `expires_at`, but treat them as secrets.

## Request

| Field | Type | Notes |
|---|---|---|
| `model` | string | required, e.g. `google/veo-3.1` |
| `prompt` | string | required except for upscale models / image-only generation |
| `duration` | int | seconds; must be in the model's `supported_durations` |
| `resolution` | string | `360p`, `480p`, `720p`, `768p`, `1080p`, `1K`, `2K`, `4K` (model dependent) |
| `aspect_ratio` | string | `16:9`, `9:16`, `1:1`, `4:3`, `3:4`, `3:2`, `2:3`, `21:9`, `9:21` |
| `size` | string | exact pixels `WxH`, interchangeable with resolution + ratio |
| `frame_images` | array | `[{"type":"image_url","image_url":{"url":"..."},"frame_type":"first_frame"}]` - image-to-video |
| `input_references` | array | reference images (style/content), or the source `video_url` for upscaling |
| `generate_audio` | bool | omitted = provider default; check the model's `generate_audio` |
| `seed` | int | where supported |
| `previous_job_id` | string | continue/extend a completed job (model must support it) |
| `upscale_factor`, `creativity` | number/int | upscale models only |
| `callback_url` | string | https webhook instead of polling |
| `provider` | object | `only` / `order` / `ignore`; no price sorting, no fallbacks for jobs |

`frame_images` wins over `input_references` when both are sent (image-to-video mode).
Unsupported `duration`/`resolution`/`aspect_ratio` values return 400 with the
allowed list, so check `GET /api/v1/videos/models` first.

## Poll response

```json
{
  "id": "abc123", "status": "completed",
  "unsigned_urls": ["https://openrouter.ai/api/v1/videos/abc123/content?index=0"],
  "usage": {"cost": 0.25, "is_byok": false}
}
```

Statuses: `pending`, `in_progress`, `completed`, `failed`, `cancelled`, `expired`.
Calling content before `completed` returns 404; after provider deletion 410 or 5xx.

## Webhooks

`callback_url` (per request) or a workspace default. Events:
`video.generation.completed`, `.failed`, `.cancelled`, `.expired`. Envelope
`{type, created_at, data:{id, status, generation_id, model, unsigned_urls, usage}}`.
`X-OpenRouter-Idempotency-Key: <job_id>-<status>`. With a signing secret,
`X-OpenRouter-Signature: t=<ts>,v1=<hmac>` over `"{timestamp},{raw_body}"`.

## Limits and notes

- Video is **not** ZDR eligible; `zdr: true` fails routing.
- One endpoint is chosen per job and a failed submission is not retried elsewhere.
- Typical latency 30s to several minutes; poll every 10-30s.
- Long jobs can expire (max TTL) - re-submit with a shorter duration or lower resolution.
