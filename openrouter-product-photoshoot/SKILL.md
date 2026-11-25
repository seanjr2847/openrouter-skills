---
name: openrouter-product-photoshoot
description: |
  Brand-quality product images through OpenRouter: studio shot, lifestyle scene,
  hands-on closeup, Pinterest pin, hero banner, carousel, ad creative pack, virtual
  try-on, conceptual/CGI, restyle. Mode templates live in this skill (the original
  Higgsfield backend prompt enhancer is gone), so you assemble the prompt locally
  and submit it to an OpenRouter image model.
  Use when: "product photo", "studio shot", "lifestyle image", "Pinterest pin",
  "hero/banner", "carousel", "ad creative", "Meta ads", "virtual try-on",
  "model wearing", "person holding product", "closeup with hands",
  "levitating/floating/splash product", "CGI/surreal product", "restyle",
  "seasonal/aesthetic variation".
  NOT for: marketplace listing sets (openrouter-marketplace-cards), thumbnails
  (openrouter-youtube-thumbnail), brand identity work (openrouter-brandkit), plain
  text-to-image with no product (openrouter-generate).
argument-hint: "[--mode <mode>] [--count N] [prompt]"
allowed-tools: Bash
---

# Product photoshoot (OpenRouter)

Higgsfield ran a private backend enhancer that assembled the photography prompt.
That does not exist here. Instead: pick a mode, fill the mode template in
`references/mode-prompts.md`, append the user's specifics, and submit to
`bytedance-seed/seedream-5-0-pro` (photoreal product default) or
`openai/gpt-image-2.6-sunburst` (graphic/banner work with text).

## Prerequisites

`OPENROUTER_API_KEY`, `curl`, `jq`. Helper:
`openrouter-media/scripts/or-media.sh image`.

## UX rules

1. Be concise: image paths or URLs plus a one-line summary per variant.
2. Reply in the user's language; mode names stay English.
3. Ask at most 4 short questions before generating, labeled options only.
4. Skip questions whose answer is obvious from the uploaded image or earlier turns.
5. Assemble the prompt from the template - do not freehand photography vocabulary.
6. Polling is silent; deliver when the files are on disk.

## Modes

| Mode | When the user wants | Default ratio |
|---|---|---|
| `product_shot` | product on neutral / studio / catalog background | `1:1` |
| `lifestyle_scene` | product in a real environment, in use, atmosphere | `4:5` |
| `closeup_product_with_person` | tight crop with hands or partial face | `4:5` |
| `moodboard_pin` | vertical Pinterest-native aesthetic | `2:3` |
| `hero_banner` | wide website / email / campaign header | `16:9` |
| `social_carousel` | 3-10 connected slides | `4:5` |
| `ad_creative_pack` | coordinated static ad variants | `1:1` + `9:16` pair |
| `virtual_model_tryout` | product worn or used by a rendered model | `3:4` |
| `conceptual_product` | surreal / CGI / levitating / splash | `1:1` |
| `restyle` | transform an existing image's aesthetic | match source |

Mode selection is by intent, not keyword: Pinterest -> `moodboard_pin`, banner ->
`hero_banner`, multi-slide -> `social_carousel`, hands on product ->
`closeup_product_with_person`.

## Interview (max 4, labeled options)

**A. Product photo uploaded, "make me images"** - how many `[1/3/5]`, style/mood
`[Clean studio / Lifestyle / Conceptual / With a model]`, where it will be used
`[Shopify / Instagram / Pinterest / Paid ads / Website hero]`, brand colors if not
obvious.

**B. Product photo + named use case** - ask only the gaps: count, offer/mood/hook,
anything to emphasize.

**C. Text only** - can they upload a photo (much higher fidelity)? If not: category,
packaging, color, distinctive features, style, placement.

**D. Existing image, "redo / different vibe"** -> `restyle`: target aesthetic
`[Clean girl / Cottagecore / Quiet luxury / Dark academia / Y2K / Other]`, seasonal
context, what to keep vs. change.

**E. Model wearing it** -> `virtual_model_tryout`: model archetype, environment
`[Studio clean / Outdoor / Street / Editorial / Home]`, framing `[Full body /
Three-quarter / Waist up / Closeup]`.

**F. Vague** - what product, goal `[Sell / Awareness / Ads / Website]`, upload a
reference, then route to A-E.

## Generation

1. Read `references/mode-prompts.md`, take the mode's template block.
2. Fill `{{subject}}`, `{{brand}}`, `{{surface}}`, `{{palette}}`, `{{extras}}` from
   the interview. Keep the template's camera, light and material language intact.
3. Submit one call per variant (do not rely on `n` - many models return one image
   per call), varying exactly one axis per variant: angle, light, or palette.

```bash
bash "$HOME/.claude/skills/openrouter-media/scripts/or-media.sh" image \
  --model bytedance-seed/seedream-5-0-pro \
  --prompt "<assembled prompt>" \
  --ref ./product.jpg --ratio 4:5 --resolution 2K --out ./shots
```

Carousel and ad packs: generate slide 1, then reuse it as `--ref` for the rest so the
visual system stays locked, and keep the same palette and light language in each
prompt.

## Resolution and ratio

`2K` for final on Seedream (`resolution` supports 1K/1.5K/2K), `1K` for drafts.
`openai/gpt-image-2.6-sunburst` has no `resolution` field - use `--quality high` there
instead, or the call returns 400. Ratios: `1:1`, `4:5`, `5:4`, `3:4`, `4:3`, `2:3`,
`3:2`, `9:16`, `16:9`. Override the default only when the user asks or the placement
demands it.

## Delivery

Short bulleted list of files. No JSON, no job ids, no model names, no prompt dump.
If a variant failed, say so in one line.

```
3 lifestyle shots ready:
- ./shots/image-1.png
- ./shots/image-2.png
- ./shots/image-3.png
```

## Common mistakes

- Freehanding a photography prompt instead of filling the mode template.
- Using `product_shot` when the user asked for a Pinterest pin or a banner.
- Asking five questions in one message.
- Pasting the assembled prompt back to the user - they want the images.
- Generating 5 variants that differ only by seed; vary one axis deliberately.
