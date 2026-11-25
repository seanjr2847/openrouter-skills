# Image API reference (OpenRouter)

Endpoint: `POST https://openrouter.ai/api/v1/images`
Discovery: `GET https://openrouter.ai/api/v1/images/models`,
per-endpoint capabilities and price: `GET /api/v1/images/models/{author}/{slug}/endpoints`
(public, no auth needed for discovery).

## Request

| Field | Type | Notes |
|---|---|---|
| `model` | string | required, e.g. `bytedance-seed/seedream-5-0-pro` |
| `prompt` | string | required |
| `n` | int 1-10 | providers may return fewer; single-image providers reject `n > 1` |
| `resolution` | string | `512`, `768`, `1K`, `1.5K`, `2K`, `4K` (model dependent) |
| `aspect_ratio` | string | `1:1`, `16:9`, `9:16`, `4:3`, `3:4`, `3:2`, `2:3`, `4:5`, `5:4`, `21:9`, `9:21`, or `auto` |
| `size` | string | tier (`2K`) or exact pixels (`2048x2048`) where the provider accepts pixels |
| `quality` | string | `auto`, `low`, `medium`, `high` |
| `output_format` | string | `png`, `jpeg`, `webp`, `svg` (vector models), `gif` (animation models) |
| `frame_count`, `frame_duration_ms` | int | only for `output_format: gif` (2-64 frames, 20-2000 ms) |
| `background` | string | `auto`, `transparent` (needs png/webp), `opaque` |
| `output_compression` | int 0-100 | webp/jpeg only |
| `seed` | int | where supported |
| `response_format` | string | `url` (recommended, expires in 24h) or `b64_json` |
| `input_references` | array | `[{"type":"image_url","image_url":{"url":"https://... | data:image/png;base64,..."}}]` |
| `markup` | object | transparent PNG mask for edit-in-place models |
| `stream` | bool | SSE partial previews on streaming-capable models |
| `provider` | object | `only`, `order`, `ignore`, `sort`, `allow_fallbacks`, `zdr`, `data_collection` |
| `user`, `session_id` | string | grouping/tracking, never sent to the provider |

Fields are **per model**, not per API. Verified 2026-11-25:

| Model | resolution | quality | output_format |
|---|---|---|---|
| `openai/gpt-image-2.x` | not supported | auto/low/medium/high/xhigh/max | png/jpeg/webp/gif |
| `google/gemini-3-pro-image` | 1K/2K/4K | - | - |
| `google/gemini-3.1-flash-image` | 512/1K/2K/4K | - | - |
| `bytedance-seed/seedream-5-0-pro` | 1K/1.5K/2K | - | png/jpeg |
| `recraft/recraft-v4.1-vector` | not supported | - | svg only |

An unsupported field is a 400 (or a silently ignored provider field). Confirm with
`GET /api/v1/images/models/{author}/{slug}/endpoints` before a paid run.

Image-to-image: pass the source in `input_references` and describe the change in
`prompt`. Local files work as base64 data URLs, so no upload step is needed.

## Response

```json
{
  "created": 1748372400,
  "data": [{"url": "https://...", "media_type": "image/png"}],
  "expires_at": 1748458800,
  "usage": {"prompt_tokens": 0, "completion_tokens": 4175, "total_tokens": 4175, "cost": 0.04}
}
```

`usage.cost` is the real charge in USD. Download signed URLs immediately; they
expire after 24 hours. Streaming and ZDR requests return `b64_json` instead.

## Billing

All-or-nothing: completed = billed in full, failed = not billed (the request returns
502, never a partial image). A `402` with `metadata.limit_source`:
`openrouter_credits` = balance too low, `openrouter_in_flight_budget` = wait for
`Retry-After`. A `403` with `limit_source: openrouter_key_limit` = the API key's
own spending cap is used up.

## Price shape

Two shapes exist, so quote from the endpoints API rather than guessing:

- per image: `seedream-5-0-pro` $0.045 (high-res variant $0.09, input image $0.003),
  `seedream-5-5` $0.02/$0.035, `recraft-v4.1-vector` $0.08,
  `flux-3-image` $0.041 (768) to $0.607 (4K).
- per output token: Gemini image models and `gpt-image-*`. Typical single image
  lands around $0.02-0.15; read `usage.cost` after the call.
