# Media inputs

Local paths, `https://` URLs and `data:` URLs are all accepted. The helper script
inlines local files as base64 data URLs, so nothing needs to be uploaded first.

## Images as input (`input_references`)

```json
"input_references": [
  {"type": "image_url", "image_url": {"url": "https://example.com/ref.png"}}
]
```

- Image editing / restyling: pass the source image and describe only the change.
- Style guidance: pass 1-3 references and name what to borrow ("palette and lighting
  only, not the composition").
- Identity consistency: pass 1-3 photos of the same person and add an identity clause
  ("same person, same face shape, same eye spacing"). OpenRouter has no Soul training,
  so this per-request clause is the substitute.
- How many references a model accepts varies by endpoint. If a call is rejected for
  reference count, drop to one reference and retry.

## Video frames (`frame_images`)

```json
"frame_images": [
  {"type": "image_url", "image_url": {"url": "https://.../first.png"}, "frame_type": "first_frame"},
  {"type": "image_url", "image_url": {"url": "https://.../last.png"},  "frame_type": "last_frame"}
]
```

- Both frames present = the model must travel from one to the other. Keep the camera
  language single and continuous; a cut between frames produces a morph artifact.
- Only `first_frame` = classic image-to-video.
- `frame_images` beats `input_references` when both are sent.
- Models advertising `supported_frame_images: ["first_frame"]` ignore or reject
  `last_frame` - check `GET /api/v1/videos/models` first.

## Video as input

```json
"input_references": [
  {"type": "video_url", "video_url": {"url": "https://example.com/clip.mp4"}}
]
```

Used by `black-forest-labs/flux-video-edit` (edit) and
`black-forest-labs/flux-video-upscale` (upscale; send exactly one entry, no prompt).

## Chaining jobs

- Keep the local file of every accepted generation. Later edits and upscales reuse
  it, and signed download URLs expire.
- `previous_job_id` continues a completed job on models that support continuation
  (`flux-3-video`, some Seedance tiers). The new job must use the same model.
- There is no job list endpoint for video in the same way the Higgsfield CLI had;
  record job ids yourself if the user will want to revisit them.
