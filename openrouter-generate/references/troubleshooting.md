# Troubleshooting (generate)

The authoritative list lives in `openrouter-media/references/troubleshooting.md`.
Short version:

| Symptom | Fix |
|---|---|
| 400 with an allowed-values list | duration / resolution / ratio / reference count unsupported for that model - re-read the models endpoint |
| 400 mentioning chat completions | image-only model sent to the wrong endpoint - use `POST /api/v1/images` |
| 402 credits | balance too low, tell the user the amount |
| 402 in-flight budget | too many concurrent jobs, wait for `Retry-After` |
| 403 key limit | this API key's spending cap is spent |
| job pending for minutes | normal at 1080p/2K, keep polling every 10-30s |
| job expired | retry with a shorter duration or lower resolution |
| job failed on policy | rewrite the prompt instead of resending |
| 0-byte download | content URL needs the Authorization header and `index=0` |
