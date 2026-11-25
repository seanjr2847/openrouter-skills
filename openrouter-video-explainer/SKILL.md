---
name: openrouter-video-explainer
description: |
  Compatibility entry for the former Higgsfield video-explainer skill. Use when the
  user explicitly invokes video explainer or continues an existing explainer workflow.
  NOT for: new generic explainer requests (use openrouter-faceless-video), ads, single
  clips, or unrelated video edits.
argument-hint: "[topic or source files] [duration] [language] [aspect ratio]"
allowed-tools: Bash
---

# Video explainer (compatibility)

The original Higgsfield skill was a redirect: it told the agent to run the
illustrated explainer workflow of `higgsfield-faceless-video` and never to call the
`explainer_video` / `video_explainer` models.

Do the same here:

1. Use `openrouter-faceless-video` with its illustrated explainer mode
   (`references/production.md`) - narration through the TTS endpoint, one background
   clip per block, assembled with the bundled ffmpeg scripts.
2. Preserve the user's inputs and choices: topic, duration, language, aspect ratio,
   voice.
3. Do not call any `explainer_video` / `video_explainer` model. They do not exist on
   OpenRouter, and the local template path above replaces them.
4. If `openrouter-faceless-video` is not installed, say so instead of improvising a
   slide pipeline.
