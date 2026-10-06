# Core Engineering Directives & Unified Global Rules

## 1. Web Performance & PageSpeed Score >= 90 (Non-Negotiable)
- **Performance First**: Beautiful and elegant websites MUST be blazing fast. Every single change—whether adding features, animations, visual effects, or assets—MUST strictly prioritize load speed and runtime performance.
- **Target Metric**: Maintain a Google PageSpeed Insights / Lighthouse score of **minimum 90 on both Mobile and Desktop**.
- **Animation & Render Optimization**:
  - Always use hardware-accelerated CSS properties (`transform`, `opacity`, `translate3d`) for animations to guarantee smooth 60fps/120fps. Never animate layout-triggering properties (`width`, `height`, `top`, `left`, `margin`, `padding`).
  - Zero render-blocking bloat: defer non-critical scripts, pre-connect critical fonts, lazy-load offscreen media.
  - Zero Layout Shifts (CLS = 0): always define explicit aspect-ratios/dimensions for images, videos, and dynamic containers.
  - Load heavy 3D/Canvas/Lottie scripts dynamically only when scrolled into view (IntersectionObserver / on-demand).

## 2. "Less is More" & Zero Junk Code
- **Zero Junk / Bloat Code**: No unused dependencies, dead code, verbose boilerplate wrappers, or redundant helper functions.
- **Lean & Clean**: Write concise, purposeful, and self-documenting code. Every line must serve a direct, measurable purpose.
- **Native-First**: Prefer native CSS/browser APIs over pulling heavy external npm libraries for simple effects.

## 3. Automatic Skill Application (Contextual Triggering)
You must ALWAYS automatically detect, inspect, and apply relevant skills from the available skills catalog whenever the user's task matches their domain, without requiring the user to type slash commands:

- **UI, Frontend & Web Motion**: Automatically load and apply ui-ux-pro-max, frontend-design, ui-styling, emil-design-eng, gsap-framer-scroll-animation, framer-motion-animator, motion-design, or threejs-animation for any UI, animation, scroll effect, 3D graphic, landing page, or styling task.
- **Performance Audits & Optimization**: Automatically load web-perf to audit and enforce Core Web Vitals (LCP, INP, CLS) and PageSpeed metrics.
- **Visual Art & Documents**: Automatically load and apply canvas-design when creating visual graphics, posters, typography art, or stylized document layouts.
- **Complex Web Artifacts**: Automatically apply web-artifacts-builder when creating interactive React + Tailwind + shadcn web components or multi-file HTML artifacts.
- **Code Security Reviews**: Automatically load and enforce security-best-practices whenever writing backend routes, APIs, authentication logic, or doing security audits across Python, JS/TS, and Go.
- **Cloudflare Ecosystem**: Automatically load cloudflare, wrangler, workers-best-practices, durable-objects, or agents-sdk for any Cloudflare Workers/Pages/DO tasks.
- **Social & Copywriting**: Automatically apply caption, instagram-content, yt-script, or yt-batch for social media copywriting, video scripts, and marketing copy.
- **Sales & Customer Handling**: Automatically enforce customer-handling SOP and wa-close-scripts (DP 30% rule, 2-message quote split, no pushy fluff).
- **Browser Automation & QA**: Automatically use playwright, cross-browser-check, or url-screenshot for browser testing, validation, and web scraping.

## 4. Manual Skill Access & Slash Commands
- Full support for manual invocation: Whenever the user explicitly types a slash command (e.g. /caption, /ui-ux-pro-max, /yt-script, /site-review) or mentions a skill name, immediately prioritize and execute that specific skill's workflow.

## 5. Progressive Skill Loading Protocol
When any task relates to a skill's domain (either auto-detected or manually invoked), immediately read its SKILL.md using `view_file` at the start of execution to retrieve full guidelines before generating code or output.

## 6. DESIGN.md — Mandatory Frontend Standard (Non-Negotiable)
Whenever the user asks to build, redesign, or modify a **website, web app, landing page, dashboard, or any UI**:
- **Before writing any UI code**, read `DESIGN.md` in the project root. If it does not exist, copy the master from `C:\Users\mrblindside07\.gemini\config\DESIGN.md` into the project root first, then read it.
- DESIGN.md overrides any conflicting aesthetic guidance from skills (ui-ux-pro-max, frontend-design, etc.). Skills may be used for technique, never to violate DESIGN.md.
- Core rules (summary — full spec in DESIGN.md):
  - **Forbidden**: purple-blue/neon gradients, glow/blur backgrounds, floating cards with heavy drop-shadows, cliché AI-SaaS template layouts (centered hero + 3 identical feature cards + icons in colored circles).
  - **Color**: monochrome zinc/slate, high contrast, **max 1 bold accent** (deep amber or electric blue), used only on primary CTA / active state / focus ring.
  - **Typography**: Geist or Plus Jakarta Sans; strong size contrast heading vs body; muted descriptions.
  - **Layout**: generous whitespace, asymmetric grids, consistent 4/8-multiple spacing.
  - **Components**: shadcn/ui or standard Tailwind utilities; Lucide icons 16/18px thin stroke, no colored icon containers; 1px translucent borders; 150ms subtle hover + active state.
- Follow the **4-phase workflow** in DESIGN.md §7 (Structure → Typography & Components → Visual & Interaction → Per-Component Refinement) and run the §8 checklist before delivering UI code.

## 7. Proactive Clarification & Grill-Me Protocol (Zero Hesitation to Ask)
- **Zero Hesitation to Clarify**: Tidak ada batasan untuk bertanya kepada user. Kapan pun konteks proyek, spesifikasi fitur, stack teknologi, atau preferensi desain belum jelas atau masih berupa template placeholder (contoh: `[nama halaman]`, `[web referensi]`), **JANGAN PERNAH berasumsi buta atau ragu untuk bertanya**.
- **Proactive /grill-me Mindset**: Segera gunakan `ask_question` atau ajukan pertanyaan spesifik secara terstruktur untuk mengumpulkan parameter kunci yang belum lengkap sebelum mengeksekusi kode, agar hasil implementasi presisi sesuai ekspektasi.