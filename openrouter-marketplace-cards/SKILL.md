---
name: openrouter-marketplace-cards
description: |
  Marketplace product image sets through OpenRouter: compliant main image, secondary
  product images, infographics, multi-angle and detail shots, lifestyle listing
  shots, and A+ style content modules. The original Higgsfield backend held private
  marketplace compliance templates; this skill ships its own asset templates in
  references/asset-templates.md.
  Use when: "marketplace listing images", "product detail cards", "secondary product
  images", "product infographic", "lifestyle listing shot", "A+ content",
  "marketplace image set", "sales-ready product visuals".
  NOT for: brand photography without a listing context (openrouter-product-photoshoot),
  thumbnails (openrouter-youtube-thumbnail), brand identity (openrouter-brandkit),
  video/UGC ads (openrouter-generate).
argument-hint: "[--scope main|product-images|aplus|full-set] [prompt]"
allowed-tools: Bash
---

# Marketplace cards (OpenRouter)

Marketplaces reject images for concrete, boring reasons: busy backgrounds, cropped
product, overlaid text on the main image, invented badges, inconsistent scale across
the set. The templates in `references/asset-templates.md` encode those constraints.

## Prerequisites

`OPENROUTER_API_KEY`, `curl`, `jq`. Helper:
`openrouter-media/scripts/or-media.sh image`.

## UX rules

1. Reply in the user's language.
2. At most one confirmation question before running.
3. Prefer a real product photo as `--ref`. Proceed from text alone only when the
   product is unambiguous.
4. Assemble prompts from the asset templates; do not freehand compliance rules.
5. Final answer: file paths with short labels. No JSON, no job ids, no prompt dumps.

## Scope

| Scope | Produces |
|---|---|
| `main` | 1 marketplace main image |
| `product-images` | main + 5 secondary images |
| `aplus` | main + 7 A+ modules |
| `full-set` | main + 5 secondary + 7 A+ modules |

Assets: `main_image`, `infographic`, `multi_angle`, `detail_shot`, `lifestyle`,
`whats_in_box`, `aplus_hero_banner`, `aplus_pain_points`, `aplus_features`,
`aplus_ingredients`, `aplus_efficacy`, `aplus_how_to_use`, `aplus_endorsement`.

## Workflow

1. Confirm the product, the marketplace, and the scope. If the user gave a listing
   URL, read the title and key claims from it - do not invent certifications.
2. Generate `main_image` first. Every later asset uses it as `--ref` so scale,
   palette and light stay consistent.
3. Generate the remaining assets in template order, one call each.
4. Check each output against the template's checklist before delivering; regenerate
   the failures once with a sharper constraint instead of shipping them.

```bash
bash "$HOME/.claude/skills/openrouter-media/scripts/or-media.sh" image \
  --model bytedance-seed/seedream-5-0-pro \
  --prompt "<main_image template, filled>" \
  --ref ./product.jpg --ratio 1:1 --resolution 2K --out ./cards
```

Model choice: `bytedance-seed/seedream-5-0-pro` for photoreal product, 
`openai/gpt-image-2.6-sunburst` when an asset needs clean overlay text
(infographic, A+ banners). Text-bearing assets are the ones that need checking -
labels and numbers must match the user's facts exactly.

## Delivery

```
Marketplace cards ready:
- Main image: ./cards/image-1.png
- Infographic: ./cards/image-2.png
- Lifestyle: ./cards/image-3.png
```

## What this skill does not do

- It cannot guarantee a specific marketplace's current policy. State the checklist
  it followed; tell the user to verify against the live listing rules before upload.
- It does not produce video ads or UGC.
