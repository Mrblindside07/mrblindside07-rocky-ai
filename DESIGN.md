# DESIGN.md — Acuan Baku Frontend

> **WAJIB DIBACA sebelum menulis kode UI apa pun.** Semua halaman, komponen, dan website/aplikasi harus patuh pada dokumen ini. Jika ada konflik dengan selera pribadi atau template, **DESIGN.md menang**.

---

## 0. Prinsip Inti

**Tenang, padat, presisi.** Referensi rasa: Linear, Vercel, Stripe Dashboard. Hierarki dibangun lewat **tipografi, whitespace, dan kontras** — bukan lewat warna, glow, atau bayangan.

---

## 1. Larangan Keras (❌ Tidak Boleh Ada)

| Dilarang | Alasan / Pengganti |
|---|---|
| Gradien ungu-biru / neon | Pakai warna solid monokrom |
| Efek glow, blur background, blob, aurora, `backdrop-blur` dekoratif | Background solid `zinc-50` / `zinc-950` |
| Kartu "melayang" dengan `shadow-lg`/`shadow-xl`/`shadow-2xl` | Border 1px tipis, maks `shadow-sm` |
| Layout klise template SaaS AI (hero tengah + 3 kartu fitur identik + ikon dalam lingkaran warna) | Grid asimetris, konten padat |
| Ikon di dalam kotak/lingkaran berwarna | Ikon garis polos, warna teks |
| Lebih dari 1 warna aksen | Tepat 1 aksen per project |
| Emoji sebagai ikon UI | Lucide Icons |
| Animasi pada `width/height/top/left/margin/padding` | Hanya `transform` & `opacity` |

---

## 2. Palet Warna

**Dominan monokrom (zinc/slate), kontras tinggi, maksimal 1 aksen tegas.**

### Netral (Tailwind `zinc`)
| Token | Light | Dark | Pemakaian |
|---|---|---|---|
| `--background` | `zinc-50` / `#fafafa` | `zinc-950` / `#09090b` | Latar halaman |
| `--surface` | `white` | `zinc-900` | Panel, kartu |
| `--foreground` | `zinc-950` | `zinc-50` | Heading, teks utama |
| `--muted-foreground` | `zinc-500` | `zinc-400` | Deskripsi, label, meta |
| `--border` | `zinc-950/10` | `white/10` | Pembatas 1px |
| `--hover` | `zinc-950/[0.03]` | `white/[0.03]` | Hover baris/item |

### Aksen (pilih SATU per project, tulis di bagian *Project Config* bawah)
| Opsi | Nilai | Hover |
|---|---|---|
| Deep Amber | `amber-600` `#d97706` | `amber-700` |
| Electric Blue | `blue-600` `#2563eb` | `blue-700` |

**Aksen HANYA boleh dipakai untuk:** tombol CTA utama, penanda status/nav aktif, focus ring, link inline. Tidak untuk background section, heading, atau dekorasi.

---

## 3. Tipografi

**Font:** `Geist` (utama) atau `Plus Jakarta Sans`. Mono: `Geist Mono`. Muat via `next/font` atau `<link rel="preconnect">` + `font-display: swap`.

**Kontras ukuran harus tegas** — heading terasa jelas lebih besar dan lebih rapat dari body.

| Level | Class Tailwind | Catatan |
|---|---|---|
| Display / H1 | `text-4xl md:text-5xl font-semibold tracking-tight leading-[1.1]` | Berkarakter, rapat |
| H2 | `text-2xl md:text-3xl font-semibold tracking-tight` | |
| H3 / Judul panel | `text-base font-medium` | |
| Body | `text-sm md:text-[15px] leading-relaxed text-foreground` | Nyaman dibaca |
| Muted / Deskripsi | `text-sm text-muted-foreground` | Redup |
| Label / Meta | `text-xs font-medium uppercase tracking-wider text-muted-foreground` | |
| Angka / Data | `font-mono tabular-nums` | |

- Panjang baris paragraf maks `max-w-prose` (~65ch).
- Bobot maks `font-semibold`. Hindari `font-black`/`font-extrabold`.

---

## 4. Layout & Spacing

- **Skala spacing kelipatan 4/8:** `1 (4px) · 2 (8px) · 3 (12px) · 4 (16px) · 6 (24px) · 8 (32px) · 12 (48px) · 16 (64px) · 24 (96px)`. Dilarang nilai arbitrer seperti `p-[13px]`.
- **Whitespace lega antar section** (`py-16`–`py-24`), **padat di dalam komponen data** (`px-4 py-2`–`py-3`).
- **Grid asimetris**: contoh `grid-cols-12` dengan pembagian `8/4`, `7/5`, `3/9`; atau bento dengan ukuran sel berbeda. **Dilarang** 3 kartu identik berjejer sebagai pola utama.
- **Padding konsisten** per level: halaman `px-6 md:px-8`, panel `p-6`, item list `px-4 py-3`.
- Container: `max-w-7xl mx-auto` (marketing) atau full-width + sidebar (app/dashboard).
- Radius konsisten: `rounded-md` (input/tombol), `rounded-lg` (panel). Jangan campur `rounded-3xl`.

---

## 5. Komponen

- **Fondasi:** shadcn/ui (Button, Badge, Input, Table, Card, Dialog, DropdownMenu, Tabs) atau utility Tailwind standar. Jangan bikin ulang komponen yang sudah ada.
- **Panel/Kartu:** `rounded-lg border border-zinc-950/10 bg-white dark:border-white/10 dark:bg-zinc-900` — tanpa shadow tebal.
- **Tombol:**
  - Primary (CTA) → warna aksen solid.
  - Secondary → `variant="outline"` monokrom.
  - Tertiary → `variant="ghost"`.
  - Maks 1 tombol primary per area pandang.
- **Badge:** `variant="outline"` / `secondary` monokrom; aksen hanya untuk status aktif.
- **Ikon:** Lucide, `size={16}` atau `size={18}`, `strokeWidth={1.5}`, warna `currentColor`. Tanpa wadah berwarna.
- **Tabel/List:** baris padat (`py-2.5`–`py-3`), divider `border-b border-zinc-950/5`, hover sangat tipis (`hover:bg-zinc-950/[0.02]`).

---

## 6. Interaksi & Motion

- **Hover:** `transition-colors duration-150 ease-out` — subtle (perubahan warna/opacity kecil).
- **Active/klik:** `active:scale-[0.98]` atau `active:opacity-80`.
- **Focus:** `focus-visible:ring-2 focus-visible:ring-[aksen]/40 focus-visible:ring-offset-2` — wajib untuk aksesibilitas.
- Hanya animasi `transform` & `opacity`. Hormati `prefers-reduced-motion`.
- Tidak ada animasi dekoratif loop (floating, pulse glow, dll).

---

## 7. Workflow Pengerjaan UI (4 Fase — Wajib Berurutan)

### Fase 1 — Kerangka Struktur
- Monokrom murni (hitam/putih/abu). **Tanpa warna dan efek visual.**
- Fokus: grid/flexbox, posisi navigasi, hierarki penempatan konten.
- Layout padat & clean ala Linear/Vercel. **Bukan** 3 kartu identik berjejer.
- Kode **modular** (1 komponen = 1 file/blok jelas).

### Fase 2 — Tipografi & Komponen Fungsional
- Terapkan hierarki teks §3 (judul berkarakter, deskripsi muted, body nyaman).
- Ganti tombol, badge, input dengan komponen shadcn/ui / Tailwind standar.
- Spacing kelipatan 4/8 (§4).
- **Masih tanpa warna aksen.**

### Fase 3 — Sentuhan Visual & Interaksi
- Warna aksen **hanya** pada CTA utama atau penanda status aktif.
- Micro-interaction: hover 150ms subtle + active state.
- Ikon Lucide garis tipis 16/18px, tanpa kotak/lingkaran berwarna.
- Border 1px transparan (`zinc-950/10` / `white/10`) sebagai pembatas panel.

### Fase 4 — Refinement Per Komponen
- Sentuh **hanya** komponen yang diminta; jangan ubah komponen lain.
- Kurangi padding berlebih agar tidak renggang.
- Hover baris sangat tipis & halus.
- **Output hanya blok kode pengganti** untuk komponen tersebut.

---

## 8. Checklist Sebelum Kirim Kode UI

- [ ] Tidak ada gradien neon, glow, blur dekoratif, shadow tebal
- [ ] Hanya monokrom + ≤1 aksen, dan aksen hanya di CTA/status aktif
- [ ] Font Geist / Plus Jakarta Sans, kontras heading–body tegas
- [ ] Spacing kelipatan 4/8, tanpa nilai arbitrer
- [ ] Grid asimetris, bukan template SaaS klise
- [ ] Komponen shadcn/ui / Tailwind standar
- [ ] Ikon Lucide 16/18px stroke tipis, tanpa wadah warna
- [ ] Hover 150ms, active state, focus-visible ring
- [ ] Performa: Lighthouse ≥ 90, CLS = 0 (lihat global rules)

---

## Project Config

```yaml
accent: amber   # amber | blue — ganti per project
font: geist     # geist | plus-jakarta-sans
theme: light    # light | dark | both
```
