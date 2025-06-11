# Plan for Implementing Kanji Stroke Order Visualization with KanjiVG

## Overview

This plan details how to implement a secure, accessible, interactive kanji stroke order feature using sanitized KanjiVG SVGs. The feature will allow users to view and learn the correct stroke order for kanji, integrated into the KumaSanKanji application.

---

## 1. Data Source and Asset Management

**Purpose:**  

- Download [KanjiVG SVGs](https://github.com/KanjiVG/kanjivg) and store them in `priv/static/kanjivg/`.
- Name SVG files by kanji Unicode codepoint (e.g., `6f22.svg` for 漢).
- Sanitize SVGs at build time using SVGO or a custom script.
- Maintain an attribution file for KanjiVG as required by its license.

**Security:**  

- Only serve sanitized SVGs from this trusted, static folder.
- Validate kanji input to prevent path traversal or injection.

**Accessibility:**  

- All SVGs must have descriptive `alt` text.

**Testing:**  

- Add tests to ensure the correct SVG is rendered for each kanji.
- Test for resilience to missing or malformed SVGs.

---

## 2. LiveView/Component for Stroke Order

**Purpose:**  

- Create a `KanjiStrokeOrderComponent` LiveView that:
  - Accepts a kanji character.
  - Looks up and renders the corresponding KanjiVG SVG.
  - Optionally animates strokes using JavaScript (e.g., progressive reveal).

**Security:**  

- Escape all user-facing content.
- Validate all user input.
- Only authenticated users can access personalized features.
- Review any third-party JavaScript libraries used for SVG animation for vulnerabilities.

**Accessibility:**  

- Animation controls must be keyboard accessible and screen-reader friendly.

**Styling:**  

- Use Tailwind CSS for layout and controls.
- Use oklch for accent colors (e.g., highlight current stroke).
- Match the current design system for the application.

**Animation:**

- Use [kanjivganimate](https://github.com/nihongodera/kanjivganimate) js library to add support for animating the drawing in correct stroke order of the kanji.

**Error Handling:**  

- If an SVG is missing or malformed, display a user-friendly fallback message or icon.

---

## 3. Integration with Kanji Detail and Quiz Pages

**Purpose:**  

- Add a "Show Stroke Order" button or section to kanji detail and quiz pages.
- Allow users to view, replay, or step through the stroke order animation.

**Security:**  

- Ensure only validated kanji characters are used to fetch SVGs.
- Escape all rendered content.

**Testing:**  

- Add integration tests to verify the stroke order feature is available and functional on relevant pages.

---

## 4. Attribution

- Display KanjiVG attribution in the app footer or a dedicated credits page, as required by the license.

---

## 5. Change Logging

- Log all changes in `CHANGELOG.md` with the date and a brief description.
- **Example:**  
  `2025-06-04: Added Kanji stroke order visualization using sanitized KanjiVG SVGs and integrated with kanji detail and quiz pages.`

---

## 6. Security Review

- Validate all user input.
- Escape all user-facing content.
- Only serve sanitized SVGs from static assets.
- Require authentication for user-specific features.
- Use HTTPS for all communications.

---

## Next Steps

1. Download and sanitize KanjiVG SVGs, then organize them in the static assets folder.
2. Scaffold the `KanjiStrokeOrderComponent` LiveView.
3. Integrate the component into kanji detail and quiz pages.
4. Write unit, integration, and security tests.
5. Style the UI with Tailwind CSS and oklch colors.
6. Add KanjiVG attribution to the app.
7. Update `CHANGELOG.md` after each change.

---
