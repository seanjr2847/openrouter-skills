# Troubleshooting

## Auth and money

- `401 Unauthorized` - key missing or revoked. Ask the user to check
  `OPENROUTER_API_KEY`; never print it.
- `402 Payment Required`, `metadata.limit_source: openrouter_credits` - balance
  cannot cover the request. State the amount, do not retry blindly.
- `402`, `limit_source: openrouter_in_flight_budget` - too many jobs in flight.
  Wait for `Retry-After`, then retry.
- `403`, `limit_source: openrouter_key_limit` - this key's spending cap is spent.
- `404` on `/videos/{id}/content` - the job is not `completed` yet.
- `410` or `5xx` on content - the provider deleted the output. Re-generate.

## Bad requests

- `400` listing allowed values - `duration`, `resolution`, `aspect_ratio` or the
  reference count is unsupported for that model. Re-read `GET /api/v1/videos/models`
  and pick a supported value instead of resending the same payload.
- `400` mentioning chat completions - an image-only model was sent to
  `/chat/completions`. Use `POST /api/v1/images`.
- Model not found - the id changed or was retired. Re-list and remap with
  `references/model-map.md`.
- `n > 1` rejected - that provider returns one image per call. Loop the call.

## Jobs

- Stuck `pending` for minutes - normal for 1080p/2K under load. Keep polling every
  10-30s and tell the user how long it has been running.
- `expired` - exceeded the provider TTL. Re-submit shorter (4-6s) or lower resolution.
- `failed` with a content policy error - rewrite the prompt, do not resend it.
- Download produced 0 bytes - the content URL needs the Authorization header and
  `index=0`.

## Local helper

- `no working python3 found` - the helper needs Python 3; install it, or use
  `scripts/or-media-jq.sh` which needs `curl` + `jq`.
- base64 decode fails on macOS - `base64 -d` is GNU syntax, use `base64 -D`. This
  only affects the `b64_json` fallback, not the default `response_format: url`.
- Local file not found - pass an absolute path or an `https://` URL, and keep each
  reference image under about 20 MB.
