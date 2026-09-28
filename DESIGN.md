# DESIGN.md — the shared Recoup design system

> Updated: 2026-09-28. This file is the map; the detail lives with the code that ships it.

The marketing site (`recoupable.dev`) and the product app (`chat`, `app.recoupable.dev`) share one
visual system, **Recoup Sky**: a white canvas, an open blue-sky atmosphere, dark green anchors and lime
calls to action. Client projects follow their own design instructions.

## Where the truth lives

| What | Source of truth |
|---|---|
| The system: colors, type scale, components, page patterns, do and don't | `marketing/DESIGN.md` (Recoup Sky) |
| Marketing tokens in code | `marketing/app/globals.css` `:root`, plus `components/home/sky.css` and `components/agents/audience-mode.css` |
| App tokens in code, light and dark | `chat/app/globals.css` |
| Brand files (wordmark, icon) | `marketing/public/brand/` |

When this file and the code disagree, the code wins; fix this file in the same PR.

## The shared tokens

| Role | Value | Marketing | App |
|---|---|---|---|
| Canvas | `#FFFFFF` | `--paper` | `--background` |
| Ink (text) | `#152E37` | `--ink` | `--foreground` |
| Muted text | `#586F78` | `--muted` | `--muted-foreground` |
| Border | `#E2E9EB` | `--line` | `--border` |
| Soft surface | `#F0F7FA` | | `--secondary` |
| Tray surface | `#F1F3F3` | `--paper-dark` | `--muted` |
| Brand blue | `#007EBD` | `--sky-blue` | `--brand` |
| Text link and focus | `#087BAB` | `--orange` (legacy name) | `--brand-link`, `--ring` |
| Dark green anchor | `#132B26` | `--agent-paper` | `--primary` |
| Lime action | `#D6FF62` (hover `#C5F347`, text on it `#182E28`) | `--sky-lime` | `--brand-lime` |
| Sky gradient | `#0565BB` → `#0075A8` | hero image | `--sky-start`, `--sky-end` |

**Type:** DM Sans for display, UI and body; IBM Plex Mono for labels. Both are self-hosted.
**Radius:** `0.75rem` base in the app.

## Rules that hold everywhere

- Lime is for the main CTA, a selected emphasis or a decisive finding, always with dark ink on it; never
  text on white (1.15:1).
- White on `#007EBD` is 4.45:1: not a small-text pair. Links and focus rings use `#087BAB`.
- State is carried by text as well as color ("Needs review", "Saved").
- Do not reintroduce the retired themes: the orange/cream palette, the achromatic Geist Pixel system,
  or an automatic dark mode on marketing.

## Not yet on the system

`admin` (internal) still ships default shadcn greys. Moving it is a separate decision.
