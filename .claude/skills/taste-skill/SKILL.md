---
name: design-taste-frontend
description: Anti-slop frontend skill for landing pages, portfolios, and redesigns. The agent reads the brief, infers the right design direction, and ships interfaces that do not look templated. Real design systems when applicable, audit-first on redesigns, strict pre-flight check.
---

# tasteskill: Anti-Slop Frontend Skill

> Landing pages, portfolios, and redesigns. Not dashboards, not data tables, not multi-step product UI.
> Every rule below is **contextual**. None of it fires automatically. First read the brief, then pull only what fits.

---

## 0. BRIEF INFERENCE (Read the Room Before Anything Else)

Before touching code, **infer what the user actually wants**.

### 0.A Read these signals first

1. **Page kind** — landing, portfolio, redesign, editorial
2. **Vibe words** — "minimalist", "Linear-style", "Awwwards", "brutalist", "premium consumer", "Apple-y"
3. **Reference signals** — URLs, screenshots, brands named
4. **Audience** — B2B procurement vs design-conscious consumer vs recruiter
5. **Brand assets** — logo, color, type, photography (for redesigns: starting material, not optional)
6. **Quiet constraints** — accessibility-first, public-sector, kids' products (OVERRIDE aesthetic preference)

### 0.B Output a one-line "Design Read" before generating

> "Reading this as: B2B SaaS landing for technical buyers, with a Linear-style minimalist language, leaning toward Tailwind + Geist + restrained motion."

### 0.C If the brief is ambiguous, ask ONE question

> "Should this feel closer to Linear-clean or Awwwards-experimental?"

### 0.D Anti-Default Discipline

Do not default to: AI-purple gradients, centered hero over dark mesh, three equal feature cards, generic glassmorphism, Inter + slate-900. Reach past them deliberately.

---

## 1. THE THREE DIALS

- **`DESIGN_VARIANCE: 8`** — 1 = Perfect Symmetry, 10 = Artsy Chaos
- **`MOTION_INTENSITY: 6`** — 1 = Static, 10 = Cinematic / Physics
- **`VISUAL_DENSITY: 4`** — 1 = Art Gallery / Airy, 10 = Cockpit / Packed Data

**Baseline:** `8 / 6 / 4`. Override conversationally, never ask to edit this file.

### 1.A Dial Inference

| Signal | VARIANCE | MOTION | DENSITY |
| --- | --- | --- | --- |
| "minimalist / clean / calm / editorial / Linear-style" | 5-6 | 3-4 | 2-3 |
| "premium consumer / Apple-y / luxury / brand" | 7-8 | 5-7 | 3-4 |
| "playful / wild / Dribbble / Awwwards / experimental" | 9-10 | 8-10 | 3-4 |
| "landing page / portfolio / marketing site" | 7-9 | 6-8 | 3-5 |
| "trust-first / public-sector / accessibility-critical" | 3-4 | 2-3 | 4-5 |

### 1.B Use-Case Presets

| Use case | VARIANCE | MOTION | DENSITY |
| --- | --- | --- | --- |
| Landing (SaaS, mainstream) | 7 | 6 | 4 |
| Landing (Agency / creative) | 9 | 8 | 3 |
| Landing (Premium consumer) | 7 | 6 | 3 |
| Portfolio (Designer / studio) | 8 | 7 | 3 |
| Portfolio (Developer) | 6 | 5 | 4 |
| Editorial / Blog | 6 | 4 | 3 |
| Public-sector service | 3 | 2 | 5 |
| Redesign - preserve | match | match+1 | match |
| Redesign - overhaul | +2 | +2 | match |

---

## 2. BRIEF → DESIGN SYSTEM MAP

### 2.A When to reach for a real design system

| Brief reads as… | Reach for |
| --- | --- |
| Microsoft / enterprise SaaS / dashboards | `@fluentui/react-components` |
| Google-ish UI / Material-flavored | `@material/web` + Material 3 tokens |
| IBM-style B2B / enterprise analytics | `@carbon/react` + `@carbon/styles` |
| Shopify app surfaces | `polaris.js` / Polaris React |
| Atlassian / Jira-style | `@atlaskit/*` |
| GitHub-style devtool | `@primer/css` or `@primer/react-brand` |
| Public-sector UK service | `govuk-frontend` |
| US public-sector | `uswds` |
| Modern accessible React foundation | `@radix-ui/themes` |
| Modern SaaS (you own components) | `shadcn/ui` — NEVER in default state |
| Tailwind-based modern SaaS / AI marketing | Tailwind v4 utilities |

**One system per project.** Do not mix systems.

### 2.B Aesthetics (no official package — build with native CSS + Tailwind)

| Aesthetic | Implementation |
| --- | --- |
| Glassmorphism | `backdrop-filter`, layered borders. Solid-fill fallback. |
| Bento (Apple tiles) | CSS Grid with mixed cell sizes |
| Brutalism | Native CSS, monospace, raw borders |
| Editorial / magazine | Serif type, asymmetric grid, generous whitespace |
| Kinetic typography | Native CSS animations, GSAP for scroll hijacks |
| Apple Liquid Glass | **No official package.** Label clearly as approximation. |

---

## 3. DEFAULT ARCHITECTURE

### 3.A Stack
- **Framework:** React or Next.js. Default to Server Components (RSC)
- **RSC SAFETY:** Global state only in Client Components. Wrap providers in `"use client"`
- **INTERACTIVITY ISOLATION:** Motion/scroll listeners MUST be isolated leaf with `'use client'`
- **Styling:** Tailwind v4. For v4: use `@tailwindcss/postcss`, NOT the v3 postcss plugin
- **Animation:** Motion (formerly Framer Motion). Import from `motion/react`
- **Fonts:** `next/font` or `@font-face` + `font-display: swap`. Never `<link>` Google Fonts in production

### 3.B State
- Local `useState` / `useReducer` for isolated UI
- NEVER `useState` for continuous values (mouse, scroll) — use `useMotionValue` / `useTransform`

### 3.C Icons
- **Allowed:** `@phosphor-icons/react`, `hugeicons-react`, `@radix-ui/react-icons`, `@tabler/icons-react`
- **Discouraged:** `lucide-react` (only if project already uses it)
- **NEVER hand-roll SVG icons**
- **One family per project**, standardize `strokeWidth` globally

### 3.D Emoji Policy
Discouraged by default. Replace with icon-library glyphs. Override only for explicitly playful/chat/social vibes.

### 3.E Responsiveness
- `min-h-[100dvh]` NEVER `h-screen`
- Grid over flex-math: `grid grid-cols-1 md:grid-cols-3 gap-6`

---

## 4. DESIGN ENGINEERING DIRECTIVES

### 4.1 Typography

- Display: `text-4xl md:text-6xl tracking-tighter leading-none`
- Body: `text-base text-gray-600 leading-relaxed max-w-[65ch]`
- **Sans font:** Discourage Inter as default. Use `Geist`, `Outfit`, `Cabinet Grotesk`, `Satoshi`
- **SERIF DISCIPLINE (VERY DISCOURAGED):** Serif ONLY when brief names it OR aesthetic is genuinely editorial/luxury/heritage AND you can articulate why. BANNED as defaults: `Fraunces`, `Instrument_Serif`
- **EMPHASIS:** bold/italic of the SAME font, NEVER inject a serif word into a sans headline

### 4.2 Color Calibration

- Max 1 accent color, saturation < 80%
- **THE LILA RULE:** No auto purple/blue glow gradients. Use neutral bases + high-contrast singular accents
- **COLOR CONSISTENCY LOCK:** Once accent is chosen, it's used on the WHOLE page
- **PREMIUM-CONSUMER PALETTE BAN:** Banned as default for premium consumer: beige/cream backgrounds (`#f5f1ea`, `#faf7f1`), brass/clay accents, espresso near-black text. Use alternatives: Cold Luxury, Forest, Cobalt+Cream, Terracotta+Slate, Pure monochrome + pop

### 4.3 Layout Diversification

- **ANTI-CENTER BIAS:** Avoid centered hero when `DESIGN_VARIANCE > 4`. Use Split Screen, asymmetric layouts
- Exception: editorial/manifesto/launch-announcement briefs

### 4.4 Materiality, Shadows, Cards

- Use cards ONLY when elevation communicates real hierarchy
- **SHAPE CONSISTENCY LOCK:** One corner-radius scale per page

### 4.5 Interactive UI States

- **Loading:** Skeletal loaders matching final layout shape
- **Empty States:** Beautifully composed
- **Error States:** Inline for forms, contextual toasts for transient
- **Tactile Feedback:** `-translate-y-[1px]` or `scale-[0.98]` on `:active`
- **BUTTON CONTRAST CHECK:** WCAG AA (4.5:1 body, 3:1 large text). Mandatory
- **CTA BUTTON WRAP BAN:** Button text MUST fit on one line at desktop. 3 words max
- **NO DUPLICATE CTA INTENT:** One label per intent across the whole page

### 4.6 Data & Form Patterns

- Label ABOVE input. Error text BELOW input
- No placeholder-as-label. Ever.

### 4.7 Layout Discipline (Hard Rules)

- **Hero MUST fit initial viewport.** Headline max 2 lines, subtext max 20 words AND max 3-4 lines, CTAs visible without scroll
- **Hero top padding cap:** max `pt-24` at desktop
- **Hero STACK DISCIPLINE (max 4 text elements):** eyebrow OR brand strip + headline + subtext + CTAs. BANNED in hero: tagline below CTAs, trust micro-strip, bullet list, social-proof avatar row
- **"Used by" logo wall:** belongs UNDER the hero, NEVER inside it
- **Navigation:** single line at desktop, height ≤ 80px max
- **EYEBROW RESTRAINT:** Max 1 eyebrow per 3 sections. Count `uppercase tracking` instances. If count > ceil(sectionCount / 3), output fails
- **SPLIT-HEADER BAN:** "left big headline + right small explainer" pattern is BANNED
- **BENTO CELL COUNT RULE:** N items = N cells. No empty cells
- **SECTION-LAYOUT-REPETITION BAN:** Each layout family appears at most once per page (at least 4 different families across 8 sections)
- **ZIGZAG ALTERNATION CAP:** Max 2 consecutive image+text-split sections
- **Bento Background Diversity:** At least 2-3 cells need real visual variation

### 4.8 Image & Visual Asset Strategy

Priority order:
1. **Image-generation tool first** (if available — use it)
2. **Real web images:** `https://picsum.photos/seed/{descriptive-seed}/{w}/{h}`
3. **Last resort:** labeled placeholder slots + tell user what's needed

**Div-based fake screenshots are BANNED.** Real company logos via Simple Icons: `https://cdn.simpleicons.org/{slug}/ffffff`

**LOGO-ONLY rule:** logo wall = logos and nothing else. NO industry labels below logos.

### 4.9 Content Density

- Short headline (≤ 8 words) + short sub-paragraph (≤ 25 words) + one visual OR one CTA
- **No `<ul>` with bullets / `divide-y` rows for > 5 items.** Use 2-column split, card grid, tabs, carousel, marquee
- **SPEC SHEETS:** Banned as default: long table with `border-b` on every row. Use 2-col card grid, scroll-snap pills, grouped chunks

### 4.10 Quotes & Testimonials

- Max 3 lines of quote body
- No em-dashes inside quote text
- Attribution: name + role + company

### 4.11 Page Theme Lock

- ONE theme for the whole page. No section flips
- Exception: explicit "Color Block Story" with strong transition, once per page

---

## 5. CONTEXT-AWARE PROACTIVITY (tools, not defaults)

- **Magnetic Micro-physics:** Use when `MOTION_INTENSITY > 5` AND premium/playful/agency. EXCLUSIVELY with `useMotionValue`/`useTransform`
- **MOTION MUST BE MOTIVATED:** Before any animation, ask what it communicates (hierarchy, storytelling, feedback, state transition). "It looked cool" = invalid
- **MARQUEE MAX-ONE-PER-PAGE**
- **`window.addEventListener('scroll')` is BANNED.** Use Motion `useScroll()`, GSAP ScrollTrigger, IntersectionObserver, or CSS scroll-driven animations

### 5.A Sticky-Stack Canonical Skeleton (GSAP)

```jsx
"use client";
import { useRef, useEffect } from "react";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { useReducedMotion } from "motion/react";

gsap.registerPlugin(ScrollTrigger);

export function StickyStack({ cards }) {
  const ref = useRef(null);
  const reduce = useReducedMotion();

  useEffect(() => {
    if (reduce || !ref.current) return;
    const ctx = gsap.context(() => {
      const cardEls = gsap.utils.toArray(".stack-card");
      cardEls.forEach((card, i) => {
        if (i === cardEls.length - 1) return;
        ScrollTrigger.create({
          trigger: card,
          start: "top top",
          endTrigger: cardEls[cardEls.length - 1],
          end: "top top",
          pin: true,
          pinSpacing: false,
        });
        gsap.to(card, {
          scale: 0.92,
          opacity: 0.55,
          ease: "none",
          scrollTrigger: {
            trigger: cardEls[i + 1],
            start: "top bottom",
            end: "top top",
            scrub: true,
          },
        });
      });
    }, ref);
    return () => ctx.revert();
  }, [reduce]);

  return (
    <div ref={ref}>
      {cards.map((card, i) => (
        <div key={i} className="stack-card sticky top-0 min-h-[100dvh] flex items-center justify-center">
          {card}
        </div>
      ))}
    </div>
  );
}
```

Critical: `start: "top top"`, `pin: true`, cleanup via `ctx.revert()`.

### 5.B Horizontal-Pan Canonical Skeleton (GSAP)

```jsx
"use client";
import { useRef, useEffect } from "react";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";

gsap.registerPlugin(ScrollTrigger);

export function HorizontalPan({ children }) {
  const wrap = useRef(null);
  const track = useRef(null);

  useEffect(() => {
    if (!wrap.current || !track.current) return;
    const ctx = gsap.context(() => {
      const distance = track.current.scrollWidth - window.innerWidth;
      gsap.to(track.current, {
        x: -distance,
        ease: "none",
        scrollTrigger: {
          trigger: wrap.current,
          start: "top top",
          end: () => `+=${distance}`,
          pin: true,
          scrub: 1,
          invalidateOnRefresh: true,
        },
      });
    }, wrap);
    return () => ctx.revert();
  }, []);

  return (
    <section ref={wrap} className="relative overflow-hidden">
      <div ref={track} className="flex h-[100dvh] items-center">
        {children}
      </div>
    </section>
  );
}
```

### 5.C Scroll-Reveal Stagger (Motion, no GSAP needed)

```jsx
"use client";
import { motion, useReducedMotion } from "motion/react";

export function RevealStagger({ items }) {
  const reduce = useReducedMotion();
  return (
    <ul className="grid gap-6">
      {items.map((item, i) => (
        <motion.li
          key={item}
          initial={reduce ? false : { opacity: 0, y: 24 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, amount: 0.3 }}
          transition={{ duration: 0.6, delay: i * 0.06, ease: [0.16, 1, 0.3, 1] }}
        >
          {item}
        </motion.li>
      ))}
    </ul>
  );
}
```

### 5.D Forbidden Animation Patterns

- `window.addEventListener("scroll", ...)` — BANNED
- `useState` for scroll progress — BANNED (re-renders on every frame)
- `rAF` loops touching React state — use `useMotionValue`
- **NEVER mix GSAP / Three.js with Motion in the same component tree**

---

## 6. PERFORMANCE & ACCESSIBILITY

### 6.A Hardware Acceleration
Animate ONLY `transform` and `opacity`. Never `top`, `left`, `width`, `height`.

### 6.B Reduced Motion (mandatory)
Any `MOTION_INTENSITY > 3` MUST honor `prefers-reduced-motion`. Infinite loops, parallax, scroll-hijack, magnetic physics MUST collapse to static.

### 6.C Dark Mode (mandatory for consumer-facing)
Design for BOTH modes from the start. Use Tailwind `dark:` OR CSS variables (pick one). No pure `#000000` or `#ffffff`.

### 6.D Core Web Vitals
- LCP < 2.5s. Hero image: `next/image priority`
- INP < 200ms. Heavy work off main thread
- CLS < 0.1. Reserve space for images, fonts, embeds

---

## 9. AI TELLS (Forbidden Patterns)

### 9.G EM-DASH BAN (most violated Tell)

**Em-dash (`—`) is COMPLETELY banned.** Zero em-dashes anywhere:
- Headlines, eyebrows, pills, button text, image captions, body copy, quotes, attribution, alt text
- Restructure sentences: two sentences with period, comma, or colon
- Date ranges: hyphen `2018-2026`. Number ranges: hyphen `€40-80k`

Only permitted dash: regular hyphen `-`

### Other Banned Patterns

- NO version labels in hero (V0.6, BETA, EARLY ACCESS)
- NO section-number eyebrows (`001 · Capabilities`)
- NO `border-t` + `border-b` on every row of a long list
- NO middle-dot (`·`) spam — max 1 per line
- NO decorative colored status dots on every row
- NO floating top-right sub-text in section headings
- NO locale/city/time/weather strips unless brief demands it
- NO scroll cues (`↓ scroll`, `Scroll to explore`)
- NO div-based fake product UI in the hero
- NO "Quietly trusted by" / "From the field" / "Field notes" style poetic labels

---

## 13. OUT OF SCOPE

This skill is NOT for:
- Dashboards / admin panels (use Fluent, Carbon, Atlassian, Polaris)
- Data tables (use TanStack Table or AG Grid)
- Multi-step forms / wizards
- Code editors
- Native mobile

---

## 14. FINAL PRE-FLIGHT CHECK

Run EVERY box before outputting code. If any fails, output is not done.

- [ ] Brief inference declared (one-liner Design Read)?
- [ ] Dial values explicit and reasoned?
- [ ] Design system chosen correctly (Section 2)?
- [ ] ZERO em-dashes (`—`) anywhere?
- [ ] Page Theme Lock: ONE theme for whole page?
- [ ] Color Consistency Lock: one accent across all sections?
- [ ] Shape Consistency Lock: one corner-radius system?
- [ ] Button Contrast Check: every CTA text readable against background (WCAG AA 4.5:1)?
- [ ] CTA Button Wrap: no label wraps at desktop?
- [ ] Serif discipline: NOT Fraunces or Instrument_Serif as default?
- [ ] Premium-consumer palette check: NOT beige+brass+espresso?
- [ ] Hero fits viewport: headline ≤ 2 lines, subtext ≤ 20 words, CTA visible without scroll?
- [ ] Hero top padding: max `pt-24`?
- [ ] Hero stack discipline: max 4 text elements?
- [ ] EYEBROW COUNT: ≤ ceil(sectionCount / 3)?
- [ ] Split-Header Ban: no left-headline + right-explainer pattern?
- [ ] Zigzag cap: no 3+ consecutive image+text-split sections?
- [ ] No Duplicate CTA Intent?
- [ ] Logo wall = logos only (no category labels)?
- [ ] Bento background diversity (at least 2-3 non-white cells)?
- [ ] Logo wall uses SVG logos (Simple Icons), NOT plain text wordmarks?
- [ ] Motion motivated: every animation justified in one sentence?
- [ ] Marquee max-one-per-page?
- [ ] Navigation on ONE line at desktop, height ≤ 80px?
- [ ] Section-Layout-Repetition: ≥ 4 different layout families?
- [ ] Bento exact cell count (N items = N cells)?
- [ ] Real images used (no div fake screenshots)?
- [ ] No pills/labels overlaid on images?
- [ ] Reduced motion wrapped for `MOTION_INTENSITY > 3`?
- [ ] Dark mode tokens defined and tested in both modes?
- [ ] Mobile collapse explicit for high-variance layouts?
- [ ] `min-h-[100dvh]`, never `h-screen`?
- [ ] No AI Tells from Section 9 (Inter as default, AI-purple, three-equal cards, John Doe, Acme)?
- [ ] Core Web Vitals plausibly hit?
