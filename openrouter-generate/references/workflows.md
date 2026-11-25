# Workflows without a workflow API

Higgsfield exposes named workflows (`draw_to_video`, `reframe`). OpenRouter has
models, not workflows, so these become either a single model call or a local step.

## Edit an existing video (was `draw_to_video`)

`black-forest-labs/flux-video-edit` with the source as a `video_url` in
`input_references` and a prompt describing the change.

```bash
bash "$HOME/.claude/skills/openrouter-media/scripts/or-media.sh" video \
  --model black-forest-labs/flux-video-edit \
  --prompt "replace the sky with a storm, keep the camera move and subject motion" \
  --ref ./clip.mp4 --out ./out
```

Keep the change scoped. "Recolor the jacket" survives; "make it a different scene"
usually comes back with a different camera move.

## Upscale

```bash
bash "$HOME/.claude/skills/openrouter-media/scripts/or-media.sh" video \
  --model black-forest-labs/flux-video-upscale --ref ./clip.mp4 --out ./out
```

No prompt. Priced per megapixel-second, so a 4K pass on a long clip is the expensive
case - tell the user the duration before running it.

## Reframe to another aspect ratio (was `reframe`)

No model does this well. Two honest options:

1. Local, free, lossless: crop or pad with ffmpeg.
   ```bash
   ffmpeg -i in.mp4 -vf "crop=ih*9/16:ih" -c:a copy out-9x16.mp4
   ```
2. Regenerate at the target `aspect_ratio` with the original first frame. Costs a
   full job; only worth it when the composition must change.

## Extend a clip

Re-submit with `previous_job_id` on a continuation-capable model, or generate a new
segment from the last frame of the first clip (`first_frame` = extracted frame).
Extract with:

```bash
ffmpeg -sseof -0.1 -i clip.mp4 -frames:v 1 last.png
```

## First and last frame (transition)

The most reliable two-image path: generate or pick both frames as stills first, then
one video job with `frame_images`. Describing the motion between them in the prompt
("slow push in, no cuts, camera stays level") is what keeps the model from inventing
a cut.

## Image sequence -> video (scroll sites, slideshows)

The website skills need a single continuous film, not clips. Generate one job, then
extract frames locally (`ffmpeg -vf fps=12`) instead of generating frames per scroll
position. That is what keeps the scroll smooth and the bill small.
