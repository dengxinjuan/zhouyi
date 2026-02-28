# Zhouyi (周易) — I Ching Flutter App

A Flutter divination app themed around the I Ching / Book of Changes (周易). Dark, cosmic, minimalist UI with one primary action per screen. All visuals are pure Flutter — no image assets.

- **Version:** 1.0.0+1 | **Flutter channel:** Stable | **Dart SDK:** ^3.7.0
- **Platforms:** Android, iOS, Web, macOS, Linux, Windows

---

## Design Principles

- Dark, cosmic, minimalist UI
- One primary action per screen
- No clutter, no menus on the home screen
- Calm animations (slow, intentional)
- Premium, introspective feeling (not fortune-teller style)
- All visuals drawn via `CustomPainter` — zero image assets

---

## Screens

### 1. HomeScreen (`lib/screens/home_screen.dart`)
- Dark purple/black gradient background
- `StarFieldPainter` background (shared widget)
- Rotating bagua (八卦) ring — 40s animation loop, 8 proper trigrams (☰☷☳☵☶☴☲☱) with solid/broken lines
- Counter-rotating yin-yang (太极) symbol with gold glow (30s, counter-clockwise)
- Bilingual header: "易占未来" / "I Ching & Fortune"
- CTA: "开始占卜 / Start Divination" → navigates to ShakeScreen

### 2. ShakeScreen (`lib/screens/shake_screen.dart`)
- Tap anywhere to increment count 0 → 6 (simulating coin shakes)
- Pulsing energy ring (4s breathing animation)
- 6 ancient coins orbiting the ring with sinusoidal wobble (18s rotation cycle)
- Progress bar fills with easing + gold glow shadow on each tap
- After 6 taps → navigates to FormingScreen

### 3. FormingScreen (`lib/screens/formed_screen.dart`)
- Hexagram builds in with blur dissolve effect
- 18 floating purple particles in circular orbital motion
- Text: "解卦 / Hexagram: Forming"
- Auto-transitions to ResultScreen after ~1.8s via fade

### 4. ResultScreen (`lib/screens/result_screen.dart`)
- Staggered entrance: hex scale/fade → text fade → button fade
- 6 hexagram lines drawn bottom-to-top with traveling light sweep
- Loads random hexagram from data; shows name, judgment, summary, and one random line
- "ASK AGAIN" button → returns to HomeScreen  
- **Note:** Data is loaded but the layout/design does not yet reflect it well — see [Next: Result screen](#next-result-screen) below.

---

## Data: 64 hexagrams (`assets/data/hexagrams.json`)

- **Schema:** `_meta` (binary_convention: bottom_to_top, yin: 0, yang: 1) + `hexagrams` array. Each item: `id`, `name_cn`, `name_en`, `binary` (6 chars), `classical` (judgment_cn, lines_cn 1–6), `modern` (summary_cn/en, lines_explained_cn/en 1–6). Source: [ctext.org Book of Changes](https://ctext.org/book-of-changes).
- **Flow:** ShakeScreen (6 taps) → `loadHexagrams()` → `getRandomHexagram()` → FormingScreen(hexagram) → ResultScreen(hexagram). Result shows one random line (classical + modern) in addition to judgment and summary.
- **Validation:** All 64 entries present, IDs 1–64 in King Wen order; duplicate binaries for 45 萃 and 48 井 were corrected (now 000110 and 011010 respectively).

---

## Route transitions (purple + stars)

- **Shake → Forming** and **Forming → Result** use a custom transition: theme purple gradient with animated moving stars (`TransitionBackground` + `AnimatedStarFieldPainter` in `lib/widgets/star_field.dart`).
- Transition duration: 700 ms. Stars drift and twinkle; gradient stays clearly purple (no black flash).
- **FormingScreen** fade-out reveals purple (`0xFF1A1238`) so the handoff to Result stays purple. App theme uses `scaffoldBackgroundColor: 0xFF090811` and per-screen `Scaffold.backgroundColor` where needed to avoid white blink.

---

## Shared Widget

- **StarField** (`lib/widgets/star_field.dart`) — reusable starfield background painter; includes `AnimatedStarFieldPainter` and `TransitionBackground` for route transitions

---

## Project Structure

```
lib/
├── main.dart
├── data/
│   └── hexagram_data.dart      # loadHexagrams(), getRandomHexagram()
├── models/
│   └── hexagram.dart           # Hexagram, fromJson, lines from binary
├── screens/
│   ├── home_screen.dart
│   ├── shake_screen.dart
│   ├── formed_screen.dart
│   └── result_screen.dart
└── widgets/
    └── star_field.dart
assets/data/
└── hexagrams.json              # 64 hexagrams (King Wen order)
```

---

## Recent work (summary)

- **Hexagram data:** Added hexagrams 36–64 to `assets/data/hexagrams.json` so all 64 King Wen hexagrams are present with classical (judgment + 6 lines) and modern (summary + line explanations in CN/EN).
- **Validation:** Checked completeness, order, and schema; found and fixed two duplicate binary codes: **45 萃** → `000110`, **48 井** → `011010`. All 64 binaries are now unique and match the bottom-to-top convention.
- **Result flow:** Shake → Forming → Result already passes the selected hexagram and shows name, judgment, summary, and one random line; the **result screen layout does not yet reflect the data well** (see next plan).

---

## Improvement Plan

Comparison against the Figma Make reference design (`I Ching Divination App UI`).

### ✅ Completed
- [x] Replace Bagua ring with proper 8-trigram symbol (solid/broken lines per trigram)
- [x] Counter-rotating Yin-Yang inside the Bagua ring
- [x] Purple transition with moving stars between Shake→Forming and Forming→Result; fixed white blink and forming→result black flash (theme/scaffold backgrounds + transition layer)

### 🔴 Critical (Core Functionality)

**1. Hexagram data model & random selection** ✅ (data complete; UI pending)
- `Hexagram` model and `hexagrams.json` (all 64) with classical + modern text; `loadHexagrams()`, `getRandomHexagram()`; hexagram passed Shake → Forming → Result.
- **Remaining:** Result screen design/layout does not yet reflect the data properly — fix in next session (see **Next: Result screen** below).

**Next: Result screen (data ↔ design)**  
- Redesign or adjust ResultScreen so the loaded hexagram (name_cn/en, judgment_cn, summary, selected line text) is clearly visible and well laid out. The current design does not reflect the data properly.

**2. Real shake sensor support**
- Add `sensors_plus` to `pubspec.yaml`
- Replace the tap counter in ShakeScreen with accelerometer input
- Keep tap as a desktop/web fallback
- Handle iOS 13+ motion permission

### 🟡 Important (Experience)

**3. Music player**
- Add `just_audio` or `audioplayers` package
- Implement ambient background music toggle
- Wire up the existing sound icon button in HomeScreen

**4. Haptic feedback**
- Add `HapticFeedback.mediumImpact()` on each shake/tap count increment in ShakeScreen

### 🟢 Polish

**5. Animated cosmic background**
- Upgrade `StarFieldPainter` from 12 static stars to slowly drifting/twinkling particles
- Adds life to every screen without cluttering the UI

**6. Bottom navigation bar**
- Add a `BottomNavigation` widget for future sections (e.g. History, Learn)
- Plan the nav structure before implementing additional screens

---

## Next Steps

- [x] Hexagram data JSON + mapping (all 64 in King Wen order; validated, duplicate binaries fixed)
- [ ] **Result screen:** Fix layout/design so the loaded hexagram data is clearly reflected (names, judgment, summary, line content); current data does not show well in the design
- [ ] Add shake sensor support (`sensors_plus` package)
- [ ] Add haptic feedback on tap/shake
- [ ] Wire up audio button

---

## Getting Started

```bash
flutter pub get
flutter run
```

For help getting started with Flutter, see the [online documentation](https://docs.flutter.dev/).
