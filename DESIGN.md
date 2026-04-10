# DESIGN.md — Recoupable Design System

> Updated: 2026-04-09

## 1. Product Context

Recoupable is an **AI agent platform for the music industry**. Artists, managers, and labels use AI agents to handle marketing, analytics, content creation, and growth — so they can focus on music.

The product has multiple frontends:

| App | Role | URL |
|-----|------|-----|
| `chat` | Main product — AI chat + agent tools | chat.recoupable.com |
| `marketing` | Public website, blog, landing pages | recoupable.com |
| `admin` | Internal dashboard | (internal) |
| `docs` | API documentation | developers.recoupable.com |

This DESIGN.md is the **shared source of truth** across all frontends. App-specific overrides are noted where they diverge.

---

## 2. Visual Philosophy

**Vercel-grade minimalism with music-industry soul.**

The interface is achromatic by default — near-black on white (light mode) or near-white on near-black (dark mode). Color enters the UI through content, not chrome: album art, artist photos, and status indicators provide the color. The UI stays out of the way.

**Core tension:** The product lives at the intersection of **music** (emotional, editorial) × **business** (structured, bold) × **technology** (clean, systematic) × **AI** (lo-fi, machine texture). Each layer has its own typeface. This isn't decoration — it's information architecture.

**What we borrow from Vercel:**
- Shadow-as-border technique instead of CSS `border`
- Achromatic palette with functional accent colors only
- Aggressive negative letter-spacing on display type
- Gallery-level whitespace — sections breathe
- `#0a0a0a` instead of `#000000` — the micro-warmth matters

**What makes Recoupable distinct:**
- **Geist Pixel Square as the display font** — the single biggest differentiator. Every other tech company uses clean sans-serifs for headlines; Recoupable uses a bitmap pixel font at massive sizes. It reads as "built by machines" and is instantly recognizable.
- Four-font system (Vercel uses one) — each font is a brand "voice"
- Instrument Serif reserved for editorial moments (blog, pull quotes) — not product UI
- Artist content (album art, profile images) is the primary color source

---

## 3. Color Palette & Roles

### Semantic Tokens

All colors are defined as CSS custom properties. Light mode is `:root`, dark mode is `[data-theme="dark"]`.

| Token | Role | Light | Dark |
|-------|------|-------|------|
| `--brand` | Primary brand accent | `#000000` | `#ffffff` |
| `--brand-hover` | Brand hover state | `#1a1a1a` | `#e5e5e5` |
| `--brand-muted` | Subdued brand | `#6b6b6b` | `#999999` |
| `--background` | Page background | `#ffffff` | `#0a0a0a` |
| `--foreground` | Primary text | `#0a0a0a` | `#ededed` |
| `--muted` | Subtle surface | `#f7f7f7` | `#151515` |
| `--muted-foreground` | Secondary text | `#6b6b6b` | `#a0a0a0` |
| `--border` | Borders, dividers | `#e8e8e8` | `#222222` |
| `--card` | Card background | `#ffffff` | `#0a0a0a` |
| `--card-foreground` | Card text | `#0a0a0a` | `#ededed` |
| `--secondary` | Secondary surface | `#f0f0f0` | `#1a1a1a` |
| `--primary` | Primary CTA background | `#0a0a0a` | `#ededed` |
| `--primary-foreground` | Primary CTA text | `#ffffff` | `#0a0a0a` |
| `--input` | Input borders | `#e8e8e8` | `#222222` |
| `--destructive` | Error, danger | `#ef4444` | `#ef4444` |
| `--ring` | Focus ring | `#0a0a0a` | `#ededed` |
| `--sky` | Accent surface (sky blue) | `#e8f1f8` | `#0f1a24` |

### Functional Colors (not mode-dependent)

| Token | Hex | Use |
|-------|-----|-----|
| Success | `#22c55e` | Positive status, completed tasks |
| Warning | `#f59e0b` | Caution states, pending |
| Info | `#0070f3` | Informational, links in some contexts |

### Agent Status Colors

These are used in the chat app for AI agent operation states:

| State | Light | Dark | Use |
|-------|-------|------|-----|
| Active / Processing | `--brand` on `--sky` | `--brand` on `--sky` | Agent is working |
| Complete | `#22c55e` on its `0.08` tint | Same | Task finished |
| Error | `--destructive` on its `0.08` tint | Same | Task failed |
| Idle | `--muted-foreground` | Same | Agent waiting |

### Shadow-as-Border System (from Vercel)

Use `box-shadow` instead of CSS `border` for all card and container outlines:

```css
/* Standard border — replaces border: 1px solid */
box-shadow: 0px 0px 0px 1px var(--border);

/* Card with subtle elevation */
box-shadow:
  0px 0px 0px 1px var(--border),
  0px 2px 4px rgba(0, 0, 0, 0.04);

/* Elevated card (hover or featured) */
box-shadow:
  0px 0px 0px 1px var(--border),
  0px 4px 8px rgba(0, 0, 0, 0.06),
  0px 8px 16px -4px rgba(0, 0, 0, 0.04);
```

**Why shadow-as-border:** It avoids box model interference, enables smoother rounded corners, and allows multi-layer depth in a single declaration. This is the Vercel technique — we use it everywhere.

---

## 4. Typography

### Font Stack

| Font | CSS Variable | Represents | Role |
|------|-------------|-----------|------|
| Geist Pixel Square | `--font-geist-pixel-square` / `.font-pixel` | The Machine | H1, H2, pricing, CTA headlines — bold, lo-fi, unmistakable |
| Plus Jakarta Sans | `--font-ui` / `.font-ui` | The Business | H3–H6, buttons, nav, card titles — structured, bold |
| Geist Sans | `--font-geist-sans` | The Technology | Body text, descriptions, subtitles — clean infrastructure |
| Instrument Serif | `--font-display` / `.font-display` | The Music | Editorial moments, pull quotes, blog titles — emotional warmth |

**Geist Pixel is the brand signature.** The bitmap/pixel font at display sizes is what makes Recoupable instantly recognizable. It says "built by machines, for the music industry." Every other AI company uses clean sans-serifs — the pixel font is the differentiator.

**Why four fonts:** Each serves a non-overlapping role. Remove any one and the hierarchy collapses or the personality flattens. Every font is load-bearing.

### Type Scale

Sizes use `clamp()` for fluid responsiveness across breakpoints.

| Class | Size | Line Height | Tracking | Font | Used For |
|-------|------|-------------|----------|------|----------|
| Hero H1 | `clamp(2.75rem, 8vw, 5.5rem)` | 1.05 | -0.01em | Geist Pixel Square | Hero headline — the biggest thing on the page |
| Section H2 | `clamp(2rem, 4.5vw, 3.25rem)` | tight | tight | Geist Pixel Square | Section headers across the page |
| CTA H2 | `clamp(2.5rem, 7vw, 5rem)` | 0.9 | tight | Geist Pixel Square | Final CTA sections — big and punchy |
| Pricing numbers | `3rem` | 1.0 | tight | Geist Pixel Square | Dollar amounts on pricing cards |
| `text-subtitle` | `clamp(1.25rem, 2vw + 0.75rem, 1.5rem)` | 1.3 | -0.01em | Plus Jakarta Sans | Subsection headers, card titles |
| `text-lead` | `clamp(1.125rem, 1.5vw + 0.75rem, 1.25rem)` | 1.5 | 0 | Geist | Intro paragraphs, subtitles |
| `text-body` | `clamp(1rem, 0.5vw + 0.9rem, 1.0625rem)` | 1.6 | 0 | Geist | Paragraphs, descriptions |
| `text-small` | `0.875rem` | 1.5 | 0.01em | Geist or Plus Jakarta | Captions, metadata |
| `text-xs` | `0.75rem` | 1.4 | 0.02em | Geist | Tags, badges, fine print |
| Pixel accent | `12px` | 1.3 | 0.05em | Geist Pixel Square | Tech labels inline (e.g., "SHIP FASTER") |

### Hierarchy Rules

```
NAV:           Plus Jakarta Sans 500 — clickable, structured
HERO H1:      Geist Pixel Square — the brand signature, massive display
HERO SUB:     Geist Sans 400 — readable, neutral, lower opacity
CTA BUTTON:   Plus Jakarta Sans 600 — bold, actionable
SECTION H2:   Geist Pixel Square — consistent display font across sections
BODY:          Geist Sans 400 — invisible infrastructure
CARD TITLE:   Plus Jakarta Sans 600 — structured
CARD BODY:    Geist Sans 400
PRICING:       Geist Pixel Square 3rem — prices feel data-driven
INLINE LABEL: Geist Pixel Square 12px uppercase — tech texture in small doses
EDITORIAL:    Instrument Serif Italic — blog titles, pull quotes, editorial moments
```

### Chat App Typography (app-specific)

In the chat interface, the type system simplifies — Geist Pixel remains the display font:

| Element | Font | Size | Weight |
|---------|------|------|--------|
| Page title | Geist Pixel Square | text-subtitle+ | 400 |
| User message | Geist Sans | text-body | 400 |
| AI response | Geist Sans | text-body | 400 |
| Agent status | Geist Pixel Square | 12px, uppercase | 400 |
| Code blocks | Geist Mono | 14px | 400 |
| Sidebar nav | Plus Jakarta Sans | text-small | 500 |
| Sidebar section label | Geist Pixel Square | 11px, uppercase | 400 |

---

## 5. Component Patterns

### Buttons

**Primary (dark)**
- Background: `var(--primary)` — `#0a0a0a` light / `#ededed` dark
- Text: `var(--primary-foreground)` — `#ffffff` light / `#0a0a0a` dark
- Padding: `8px 16px`
- Radius: `var(--radius)` (`0.75rem` / 12px)
- Font: Plus Jakarta Sans 600
- Shadow: none
- Hover: `var(--brand-hover)`

**Secondary (outline)**
- Background: transparent
- Text: `var(--foreground)`
- Shadow-border: `0px 0px 0px 1px var(--border)`
- Padding: `8px 16px`
- Radius: `var(--radius)`
- Font: Plus Jakarta Sans 500
- Hover: `var(--muted)` background

**Ghost**
- Background: transparent
- Text: `var(--foreground)`
- No border
- Hover: `var(--muted)` background

**Destructive**
- Background: `var(--destructive)`
- Text: `#ffffff`
- Same sizing as primary

### Cards & Containers

- Background: `var(--card)`
- Shadow-border: `0px 0px 0px 1px var(--border)`
- Radius: `var(--radius)` (12px)
- Padding: `24px`
- Hover (if interactive): elevate shadow to include `0px 4px 8px rgba(0,0,0,0.06)`

### Inputs

- Background: `var(--background)`
- Shadow-border: `0px 0px 0px 1px var(--input)`
- Radius: `var(--radius)`
- Padding: `8px 12px`
- Font: Geist, text-body
- Focus: `0px 0px 0px 2px var(--ring)` — visible ring replaces border on focus
- Placeholder: `var(--muted-foreground)`

### Chat Bubbles (chat app)

**User message:**
- Background: `var(--primary)`
- Text: `var(--primary-foreground)`
- Radius: `16px 16px 4px 16px`
- Max-width: `80%`

**AI response:**
- Background: `var(--muted)`
- Text: `var(--foreground)`
- Radius: `16px 16px 16px 4px`
- Max-width: `90%`

### Badges & Pills

- Background: token-tinted at `0.08` opacity (e.g., `rgba(34,197,94,0.08)` for success)
- Text: the full-strength token color
- Radius: `9999px` (full pill)
- Padding: `2px 8px`
- Font: Geist or Geist Pixel, text-xs, weight 500

### Navigation (all apps)

- Sticky top
- Background: `var(--background)` with `backdrop-filter: blur(12px)` and reduced opacity
- Shadow-border bottom: `0px 1px 0px var(--border)`
- Links: Plus Jakarta Sans, text-small, weight 500
- Active: weight 600 or underline
- CTA button: Primary dark pill

---

## 6. Spacing & Layout

### Base Unit

`4px` — all spacing is a multiple of 4.

### Spacing Scale

| Token | Value | Use |
|-------|-------|-----|
| `space-1` | `4px` | Tight gaps (icon + label) |
| `space-2` | `8px` | Inline spacing, small gaps |
| `space-3` | `12px` | Input padding, tight stacks |
| `space-4` | `16px` | Standard gap, card padding |
| `space-6` | `24px` | Card padding, section inner |
| `space-8` | `32px` | Section gaps |
| `space-12` | `48px` | Major section spacing |
| `space-16` | `64px` | Hero padding, large gaps |
| `space-20` | `80px` | Top-level section spacing |

### Grid & Containers

- Max content width: `1200px` (marketing), `960px` (docs), `100%` (chat)
- Feature sections: 2–3 column grids
- Chat: single-column, centered, max-width `768px` for message area
- Admin: sidebar (240px) + content area

### Border Radius Scale

| Token | Value | Use |
|-------|-------|-----|
| `radius-sm` | `6px` | Small elements, inline badges |
| `radius` | `12px` | Buttons, cards, inputs — the default |
| `radius-lg` | `16px` | Chat bubbles, featured cards |
| `radius-xl` | `24px` | Large panels, modal containers |
| `radius-pill` | `9999px` | Badges, pills, tags |
| `radius-full` | `50%` | Avatars, circular buttons |

---

## 7. Depth & Elevation

| Level | Shadow | Use |
|-------|--------|-----|
| 0 — Flat | None | Page background, text blocks |
| 1 — Border | `0px 0px 0px 1px var(--border)` | Shadow-as-border for most containers |
| 2 — Card | Level 1 + `0px 2px 4px rgba(0,0,0,0.04)` | Standard cards |
| 3 — Elevated | Level 1 + `0px 4px 8px rgba(0,0,0,0.06)` + `0px 8px 16px -4px rgba(0,0,0,0.04)` | Hover cards, dropdowns |
| 4 — Modal | `0px 16px 32px rgba(0,0,0,0.12)` + `0px 0px 0px 1px var(--border)` | Modals, dialogs, popovers |
| Focus | `0px 0px 0px 2px var(--ring)` | Keyboard focus on interactive elements |

**Rule:** Shadows in dark mode use `rgba(0,0,0,0.2–0.4)` instead of `0.04–0.12` — dark backgrounds need higher opacity shadows to be visible.

---

## 8. Motion & Animation

### Duration Scale

| Token | Value | Use |
|-------|-------|-----|
| `duration-fast` | `100ms` | Button press, toggle |
| `duration-normal` | `200ms` | Hover transitions, color changes |
| `duration-slow` | `300ms` | Accordion expand, sidebar slide |
| `duration-enter` | `400ms` | Modal/dialog enter |
| `duration-exit` | `200ms` | Modal/dialog exit (faster than enter) |

### Easing

- **Standard:** `cubic-bezier(0.4, 0, 0.2, 1)` — most transitions
- **Enter:** `cubic-bezier(0, 0, 0.2, 1)` — elements appearing
- **Exit:** `cubic-bezier(0.4, 0, 1, 1)` — elements leaving
- **Spring:** `cubic-bezier(0.34, 1.56, 0.64, 1)` — playful bounces (use sparingly)

### What to Animate

- **Do:** opacity, transform (translate/scale), background-color, box-shadow, border-color
- **Don't:** width, height, top/left, font-size, padding, margin

### What NOT to Animate

- Never animate layout properties (causes reflow)
- No entrance animations on page load (feels slow)
- No animations longer than 400ms (feels sluggish)
- Chat message streaming: no transition — characters appear instantly

---

## 9. Responsive Behavior

### Breakpoints

| Name | Width | Key Changes |
|------|-------|-------------|
| Mobile | `< 640px` | Single column, stacked, reduced padding |
| Tablet | `640px – 1024px` | 2-column grids, sidebar collapses |
| Desktop | `1024px – 1440px` | Full layout, sidebar visible |
| Wide | `> 1440px` | Content centered, generous margins |

### Touch Targets

- Minimum: `44px × 44px` (Apple HIG)
- Buttons: at least `36px` height on desktop, `44px` on mobile
- Nav links: adequate spacing (16px minimum gap)

### Collapsing Strategy

- Marketing hero: `text-display` scales fluidly via `clamp()`
- Nav: horizontal → hamburger below `640px`
- Feature cards: 3 → 2 → 1 column
- Chat: full-width on mobile, centered on desktop
- Sidebar: visible on desktop, drawer on mobile

---

## 10. Do's and Don'ts

### Do

- Use Geist Pixel Square for H1 and H2 headlines — it's the brand signature at display sizes
- Use shadow-as-border (`0px 0px 0px 1px var(--border)`) instead of CSS `border`
- Use `#0a0a0a` instead of `#000000` for text in light mode — pure black is harsh
- Use Geist Pixel at small sizes (12px) for inline tech labels — uppercase with wide tracking
- Let album art and artist photos provide color — the UI stays achromatic
- Use Instrument Serif Italic for editorial moments (blog titles, pull quotes) — not product UI
- Apply `backdrop-filter: blur()` on sticky navs and overlays
- Use `clamp()` for fluid type sizing across breakpoints
- Define all colors as CSS custom properties — never hardcode hex in components
- Provide both light and dark mode values for every token
- Use `tracking-tight` on pixel font headlines — tighter tracking keeps it sharp

### Don't

- Don't use Geist Pixel for body copy or paragraphs — it's for headlines and labels only
- Don't use Instrument Serif for product UI headlines — that's Geist Pixel's role
- Don't mix Plus Jakarta Sans and Geist in the same text line
- Don't use CSS `border` on cards — use the shadow-border technique
- Don't introduce warm colors (oranges, yellows) into the UI chrome
- Don't apply color to UI chrome — color is for content and status only
- Don't add a fifth font — four is already the maximum
- Don't use Instrument Serif for buttons — serif buttons feel indecisive
- Don't use Geist Pixel at medium sizes (18–28px) — it works at display (3rem+) or tiny (12px), but the mid-range looks awkward
- Don't animate layout properties (width, height, padding, margin)
- Don't use entrance animations on page load
- Don't skip the dark mode value when adding a new CSS variable

---

## 11. App-Specific Notes

### chat (chat.recoupable.com)

The chat app is the **primary product**. Its design language is stripped-down but keeps the pixel identity:
- Geist Pixel Square for page titles and section labels — maintains brand consistency
- Plus Jakarta Sans for sidebar nav and UI controls
- Geist Sans for message content
- Geist Pixel at 12px uppercase for agent status indicators ("PROCESSING", "COMPLETE")
- Message area: centered, max-width `768px`
- AI response formatting: supports markdown, code blocks (Geist Mono), and tool output cards

### marketing (recoupable.com)

The marketing site uses the **full four-font system** with Geist Pixel as the dominant display face:
- Hero H1: Geist Pixel Square at `clamp(2.75rem, 8vw, 5.5rem)` — massive, unmistakable
- All section H2s: Geist Pixel Square at `clamp(2rem, 4.5vw, 3.25rem)`
- Pricing: Geist Pixel Square at `3rem` for dollar amounts
- Inline labels: Geist Pixel at 12px for tech texture ("SHIP FASTER")
- Dot-grid background pattern for the hero section
- Instrument Serif Italic for blog titles and editorial moments (not product UI)
- More generous whitespace than the app (80px+ between sections)

### admin (internal)

- Geist Pixel Square for page titles — keeps brand consistency even internally
- Plus Jakarta Sans + Geist Sans for everything else
- Data-dense layouts — tighter spacing (use `space-2` and `space-3` more)
- Tables with shadow-border rows
- Functional-only — no editorial flair

---

## 12. Agent Prompt Reference

When generating UI components, use these prompts as starting points:

**Card:**
```
White background. No CSS border. Shadow: 0px 0px 0px 1px var(--border), 0px 2px 4px rgba(0,0,0,0.04).
Radius 12px. Title: Plus Jakarta Sans 600 at text-subtitle. Body: Geist 400 at text-body.
Padding 24px.
```

**Hero section (marketing):**
```
Centered single-column. H1: Geist Pixel Square, clamp(2.75rem, 8vw, 5.5rem),
tracking-tight, leading-[1.05], color var(--foreground).
Subtitle: Geist Sans 400, clamp(1.0625rem, 1.6vw, 1.25rem), color var(--foreground)
at 45% opacity. Primary CTA: Plus Jakarta Sans 600, var(--primary) bg, 12px radius.
Dot-grid background: 64px squares at 5% opacity. Massive vertical spacing.
```

**Chat message (AI response):**
```
Background var(--muted). Text var(--foreground). Geist Sans 400 at text-body.
Radius 16px 16px 16px 4px. Max-width 90%. Padding 12px 16px.
Agent status below: Geist Pixel Square 12px uppercase, var(--muted-foreground).
```

**Nav bar:**
```
Sticky top. Background var(--background) at 80% opacity + backdrop-filter blur(12px).
Shadow-border bottom: 0px 1px 0px var(--border). Logo left.
Links: Plus Jakarta Sans 500, text-small, var(--foreground).
CTA: Primary button right-aligned.
```
