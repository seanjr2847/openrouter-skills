---
name: openrouter-websites
description: |
  Build and ship a real website locally: design brief, reference boards, asset
  system, React/Next.js implementation, optional scroll-scrubbed film site, SEO and
  OG metadata, QA, then deploy to Vercel. Media (stills, the scroll film) is
  generated through OpenRouter instead of the Higgsfield website platform.
  Use when: "build me a website", "make a landing page", "portfolio", "marketing
  site", "scroll website", "scroll-scrub landing page", "make the page play a video
  as I scroll", "deploy this site".
  NOT for: single image/video generation (use openrouter-generate), product photos
  (openrouter-product-photoshoot), marketplace cards (openrouter-marketplace-cards),
  thumbnails (openrouter-youtube-thumbnail), brand systems (openrouter-brandkit).
argument-hint: "[what to build] [--animated|--static]"
allowed-tools: Bash
---

# OpenRouter website builder

The original Higgsfield skill created, hosted and deployed a Cloudflare Worker app
through `higgsfield website ...`. There is no such platform here: you build a normal
local project, generate the media through OpenRouter, and deploy it yourself.

Two shapes:

- **Static / marketing site** - Next.js or Astro, content-first, no generated media
  beyond images. Use `references/design-recipe.md` and
  `references/design-taste-frontend.md`.
- **Animated scroll-scrub site** (recommended default when the user wants a "wow"
  landing page) - one continuous film plays as the visitor scrolls, with HTML
  chapters over it. Owned by `references/scroll-scrub.md` and its three asset files.

## Prerequisites

1. `OPENROUTER_API_KEY`, `curl`, `jq`, `ffmpeg`, `node`/`bun`, `git`.
2. A deploy target. Default Vercel (`npx vercel`), or Cloudflare Pages / Netlify if
   the user prefers. Ask once, up front, and remember the answer.

## Flow

1. **Intake (one message, one question at a time).** What the site sells, audience,
   language, 3-6 sections, brand colors/fonts if any, CTAs, and - mandatory -
   **animated or static**. Never skip that question; animated is the recommended
   default when the user has no opinion.
2. **Design brief.** Write `design-brief.md`: journey shape (`single-shot` for the
   animated path), the journey in beats, world grammar, mobile framing, cost shape,
   delivery budget. Rules in `references/scroll-scrub.md` Phase 0, general design in
   `references/design-recipe.md`.
3. **Reference boards.** 4-8 direction references with what to borrow from each
   (`references/reference-boards.md`). No boards, no build.
4. **Asset system.** Type scale, spacing, color roles, radii, shadows, motion
   tokens, plus which images are generated vs. supplied
   (`references/asset-system.md`).
5. **Media.** Stills and the film go through `openrouter-generate` /
   `openrouter-media`. For the scroll film: one continuous job, audio off,
   `frame_images` for the first/last frame if the user supplied both, otherwise
   text-to-video. State the per-second price and the total before submitting.
6. **Build.** Static: sections + `references/design-taste-frontend.md` rules.
   Animated: `references/scroll-scrub-asset-react.md` and
   `references/scroll-scrub-asset-css.md` into `components/scroll-scrub/`,
   chapters server-rendered, controller in `useEffect`, encoding per
   `references/scroll-scrub-asset-video.md`.
7. **SEO + metadata.** `references/seo.md`: title, description, canonical, OG image,
   JSON-LD, sitemap, robots. OG image is a generated still, not an empty placeholder.
8. **QA.** `references/review-rubric.md` plus the "A4 pre-delivery QA" list in
   `references/scroll-scrub.md`. Open the built page in a browser and look at it:
   first paint, mid-scroll, mobile 390px, reduced-motion, Lighthouse.
9. **Deploy.** Vercel or the target from step 1. Add `blob:` to CSP `media-src` when
   the film is loaded as a blob. Return the live URL and a one-line summary.

## Path note

The references describe a project laid out as `app/` (TanStack/Next root) with
`app/src` and `app/public`. If you build in a different layout, map those to
`src/` and `public/` and ignore platform-specific leftovers.

## Rules

1. Never write prices, reviews, staff names, credentials or claims the user did not
   provide. Placeholder text stays visibly placeholder.
2. Write each file once, complete. No write-then-patch loops, no re-reading a file
   you just wrote, batch shell commands. Turn budget is the scarce resource.
3. Speak in product terms in chat: "setting up your site", "your preview is ready",
   not branches, commits or build pipelines. Code and flags stay English.
4. Do not vision-inspect your own generations one by one; the asset-system coherence
   check is a single batched pass.
5. If the user's site will call OpenRouter at runtime (a generation app, not a
   marketing site), the key must live server-side only - a route handler or server
   action with a rate limit. Never ship it in client JavaScript. This is the one
   place the original platform rule inverts: there, generation ran on Higgsfield
   credits; here it runs on the user's own OpenRouter key.
6. Everything needed is in this skill's `references/`. Do not pull in other
   website-building skills on top of it.

## References

Design and build (kept from the original skill, generation layer removed):
`design-taste-frontend.md`, `design-recipe.md`, `asset-system.md`,
`reference-boards.md`, `image-to-code.md`, `review-rubric.md`,
`seo.md`, `security.md`,
`wow-catalog.md`, `wow-maker.md`.

Scroll-scrub (OpenRouter edition): `scroll-scrub.md`,
`scroll-scrub-asset-video.md`, `scroll-scrub-asset-react.md`,
`scroll-scrub-asset-css.md`.

Not ported, because they only made sense on the Higgsfield platform:
`quanta-design.md`, `containers.md`, `cover-animator.md`, `runtime-and-infra.md`,
`website-flow.md`, `app-flow.md`, `app-cover.md`, `app-quickstart.md`,
`app-layouts.md`, `auth.md`, `fnf-sdk.md`, `fnf-react.md`, `contest.md`, and the
`game-*` family (realtime rooms, meshy 3D, platform audio).
