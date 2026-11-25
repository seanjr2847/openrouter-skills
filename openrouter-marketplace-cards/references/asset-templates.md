# Asset templates

Each block: the prompt to assemble, the ratio, and the checklist a delivered image
must pass. Append the shared tail to every asset.

Shared tail:

> commercial product photography, true material texture, correct proportions and
> label text, no misspelled words, no invented badges or certifications, no
> watermark, no extra products.

## main_image (1:1, 2K)

> Marketplace main product image of {{subject}}. Product fills about 85% of the
> frame, centered, straight-on or a slight 3/4 angle, pure seamless white background
> (#FFFFFF), even soft lighting with no harsh shadow, no props, no text overlay, no
> background elements.

Checklist: white background, product not cropped, no text or badges, single unit
(unless the listing is a multi-pack), label readable and spelled correctly.

## infographic (1:1 or 4:5, 2K, text-bearing model)

> Clean infographic panel for {{subject}}: product on the left third, three short
> callout rows on the right with simple line icons, flat neutral background, brand
> accent {{brand}}, generous spacing, crisp sans-serif text, only the text given:
> "{{extras}}".

Checklist: every word matches the user's facts, hierarchy readable at 300px wide,
icons drawn not photo-collaged.

## multi_angle (1:1, 2K)

> Two or three views of {{subject}} arranged side by side on the same seamless light
> background, identical scale and lighting across views, front and back, subtle
> drop shadows.

Checklist: consistent scale, consistent white balance, no perspective mismatch.

## detail_shot (1:1, 2K)

> Macro detail of {{subject}} showing {{extras}} (texture, seam, cap, finish), shallow
> depth of field, raking light to reveal surface, clean neutral background.

Checklist: the detail is actually the subject, no dust or artifacts, label legible.

## lifestyle (4:5, 2K)

> {{subject}} in use in {{surface}}, natural daylight, real environment, hands or
> partial person allowed but not dominant, product clearly the focal point, muted
> palette in {{brand}}.

Checklist: product is identifiable, no brand logos you were not given, no people
facing camera unless requested.

## whats_in_box (1:1, 2K)

> Top-down flat lay of the full package contents of {{subject}}: {{extras}} laid out
> in a tidy grid on a light neutral surface, even overhead light, each item clearly
> separated.

Checklist: exact item count, no invented accessories.

## aplus_hero_banner (16:9, 2K)

> Wide brand banner featuring {{subject}}, cinematic but clean lighting, copy space
> on one side, palette {{brand}}, product sharp, background softly graded.

Checklist: no text unless supplied, safe margins for 1:1 crop.

## aplus_pain_points (1:1 or 4:5)

> Three-panel comparison: left "before" state muted and flat, right "after" state with
> {{subject}} bright and resolved, minimal iconography, no text unless supplied.

Checklist: claim is one the user can defend, no medical or absolute claims invented.

## aplus_features (1:1)

> Feature grid for {{subject}}: the product centered, four simple cards around it with
> short labels from "{{extras}}", consistent icon weight, flat neutral background.

Checklist: four items only, labels under six words, no fake specs.

## aplus_ingredients (1:1)

> Ingredient / component breakdown of {{subject}}: raw elements arranged around the
> product, each with a small label, botanical or material realism, soft daylight.

Checklist: every ingredient listed by the user, nothing added.

## aplus_efficacy (1:1)

> Before-and-after style evidence panel for {{subject}} with a neutral, honest
> presentation, same framing and lighting in both halves, no exaggerated retouching.

Checklist: no medical claims, no fabricated percentages, visibly labeled as
illustrative when it is not a real test.

## aplus_how_to_use (1:1)

> Three-step usage illustration for {{subject}} with numbered circles, simple line-art
> hands, consistent palette {{brand}}, plain background.

Checklist: steps match the user's instructions, numbers legible.

## aplus_endorsement (16:9)

> Editorial endorsement visual for {{subject}} in a magazine-review layout, no real
> publication logos, quotation marks empty for the user's own quote, muted premium
> palette.

Checklist: no real outlet names, no invented review scores, no celebrity likeness.

## Regeneration rule

If an image fails one checklist item, fix that item in the prompt and regenerate
once. Two failures on the same asset means the template does not fit the product -
say so and propose a different asset instead of burning more credits.
