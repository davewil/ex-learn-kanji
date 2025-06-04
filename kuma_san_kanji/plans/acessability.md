# Plan for Accessibility in Kanji Stroke Order Visualization

## Overview

This plan outlines how to ensure the Kanji stroke order visualization feature is accessible to all users, including those using assistive technologies. The approach follows best practices for web accessibility (WCAG), your coding instructions, and integrates with the existing KanjiVG-based implementation.

---

## 1. Semantic Markup

- Use semantic HTML elements for structure (e.g., `<figure>`, `<figcaption>`, `<button>`, `<nav>`).
- Ensure the SVG is contained within a meaningful element with a descriptive label.

---

## 2. Descriptive Alt Text and Labels

- Provide dynamic, descriptive `alt` text for each SVG (e.g., "Stroke order for 漢").
- Use `aria-label` or `aria-labelledby` for interactive controls (e.g., "Play stroke order animation", "Next stroke").

---

## 3. Keyboard Accessibility

- All interactive controls (play, pause, step, replay) must be accessible via keyboard (Tab, Enter, Space).
- Use visible focus indicators (styled with Tailwind CSS and oklch colors).
- Ensure logical tab order for all controls.

---

## 4. Screen Reader Support

- Use ARIA roles and properties to describe the SVG and controls.
- Announce changes (e.g., when a new stroke is highlighted) using `aria-live` regions if appropriate.
- Ensure all controls have clear, descriptive labels.

---

## 5. Color and Contrast

- Use oklch colors with sufficient contrast for all UI elements and highlights.
- Do not rely on color alone to convey information (e.g., use both color and shape/outline for current stroke).

---

## 6. Responsive Design

- Ensure the component is usable on all screen sizes.
- SVGs and controls should scale appropriately for mobile and desktop.

---

## 7. Error Handling

- If the SVG is missing or malformed, display an accessible error message (e.g., using `role="alert"`).

---

## 8. Testing

- Use automated accessibility testing tools (e.g., axe-core, Lighthouse) in CI.
- Add manual tests with screen readers (VoiceOver, NVDA) and keyboard navigation.
- Include accessibility checks in integration and component tests.

---

## 9. Documentation

- Document accessibility features and keyboard shortcuts in user-facing help or documentation.

---

## Next Steps

1. Update the KanjiStrokeOrderComponent to use semantic markup and ARIA attributes.
2. Add dynamic alt text and accessible labels for all controls.
3. Implement and test keyboard navigation and focus management.
4. Ensure color contrast and non-color cues for highlights.
5. Add automated and manual accessibility tests.
6. Document accessibility features for users.

---