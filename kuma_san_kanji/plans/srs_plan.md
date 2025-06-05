# Implementation Plan for SRS-Based Quiz Review System

## Overview

This plan details the steps to implement a secure, accessible, and testable Spaced Repetition System (SRS) quiz review feature for KumaSanKanji, following your coding, security, testing, and styling instructions.

---

## 1. Scaffold the `UserKanjiProgress` Ash Resource

- Define an Ash resource to track each user's kanji review state (user ID, kanji, next review date, interval, ease factor, repetitions, last result).
- Enforce authentication and authorization using both Ash policies and Phoenix plugs for all endpoints (API, LiveView, etc.), ensuring only authenticated users can access/modify their own progress.
- Prevent duplicate progress entries for the same user/kanji.
- Use parameterized queries for all data access.
- Do not expose sensitive data in code or logs.
- Document session management and token expiration strategies, including how tokens are issued, refreshed, invalidated, securely stored, and how session expiry is communicated to the user (e.g., UI notification or redirect).
- **Testing:**  
  - Use Ash's test resources and built-in utilities for isolated resource tests.
  - Add tests to verify access control, resource behavior, and unauthorized access attempts for both API and UI layers.

---

## 2. Implement the SRS Logic Module

- Implement the SM-2 algorithm (or similar) to calculate the next review date and interval based on user performance.
- Ensure all updates are parameterized and authenticated.
- Validate and sanitize all user input (e.g., answer format, length, allowed characters, required fields).
- Validate pagination and filtering parameters to prevent abuse.
- Implement rate limiting or throttling on all endpoints that accept user input, defining thresholds, lockout duration, and user/admin feedback for rate limits.
- Handle edge cases, such as when no kanji are due for review, invalid answers, kanji removed from the dataset, or corrupted/incomplete user progress records.
- Define migration strategies for when the kanji dataset is updated (e.g., new kanji added, existing kanji removed or changed), including rollback plans for failed migrations.
- Handle orphaned progress records if a kanji is removed.
- Address concurrent updates to the same progress record.
- **Testing:**  
  - Add unit tests for SRS logic, edge cases, and input validation.
  - Test for race conditions on concurrent updates.
  - Use fuzz/property-based testing for SRS logic and input validation.

---

## 3. Build the Quiz LiveView Interface

- Present kanji for review based on the SRS schedule.
- Accept and validate user answers (type, length, content, allowed characters).
- Provide immediate, user-friendly feedback and update SRS state.
- Escape all user-facing content to prevent XSS.
- Require authentication for all quiz actions.
- Ensure all UI elements are accessible (ARIA labels, keyboard navigation, screen reader support).
- Add skip-to-content links or landmark navigation for keyboard users.
- Ensure all interactive elements are operable via assistive technologies (e.g., voice control, switch devices).
- Document keyboard shortcuts and accessible navigation in the UI.
- Style the UI with Tailwind CSS and oklch colors, ensuring consistency with the existing design system.
- **Design System Compliance**: Follow the established color palette (neon and sakura colors in oklch), typography (katakana-inspired fonts), and component styling patterns used throughout the application.
- Implement pagination or lazy loading if the kanji dataset is large, with loading indicators and error handling for paginated data.
- Define sorting/filtering strategies for paginated/lazy-loaded data and ensure user progress is persisted across pages.
- Optimize queries and indexes for large datasets.
- Provide clear UI feedback for session expiry, rate limits, and major errors.
- Implement a “resume where you left off” feature for interrupted quiz sessions.
- **Testing:**  
  - Add integration tests for quiz flow, answer validation, feedback, accessibility, performance, and unauthorized access.
  - Add browser-based accessibility tests (e.g., Cypress with axe-core).

---

## 4. Write Integration and Resource Tests

- Cover the quiz flow, answer validation, SRS state updates, edge cases, and unauthorized access attempts.
- Use Ash's test resources for resource tests.
- Use Ash’s built-in testing utilities to verify resource behavior.
- Ensure all tests are isolated and do not depend on the state of the database.
- Include accessibility checks in integration tests.
- Schedule periodic accessibility audits in CI/CD.
- Provide a user feedback mechanism for accessibility issues.

---

## 5. Change Logging

- Log all changes in `CHANGELOG.md` with the date, author, a brief description, the reason for significant changes, and a reference to the related feature/issue/ticket or commit/PR for traceability.
- Use the format:  
  `YYYY-MM-DD (author): <summary of change> - <reason if significant> [#issue|commit]`

---

## 6. Security Review

- Validate all user input.
- Escape all user-facing content.
- Use parameterized queries for all data access.
- Require authentication and authorization for all user-specific data.
- Use HTTPS for all communications.
- Review for vulnerabilities such as SQL injection, XSS, and CSRF.
- Ensure user progress data is only accessible to the authenticated user and is never exposed in logs or APIs.
- Regularly review and update dependencies.
- Periodically audit logs and telemetry to ensure no sensitive or personally identifiable information is captured.

---

## 7. Error Handling and User Feedback

- Display user-friendly error messages for failed actions (e.g., failed save, invalid input, network errors).
- Handle cases where no kanji are due for review and inform the user appropriately.
- Log errors for monitoring and debugging.
- Define behavior for when kanji are removed or updated in the dataset.
- Handle corrupted or incomplete user progress records gracefully.
- Notify users if their progress is affected by kanji dataset changes (e.g., in-app notification or email).
- Perform backup/restore procedures before major migrations.

---

## 8. Accessibility

- Ensure all quiz UI elements have ARIA labels, are keyboard navigable, and screen reader friendly.
- Test with screen readers and on mobile devices.
- Test color contrast with automated tools (axe-core, Lighthouse).
- Add skip-to-content links or landmark navigation for keyboard users.
- Ensure all interactive elements are operable via assistive technologies.
- Document accessibility features and keyboard shortcuts in user help.
- Provide a user feedback mechanism for accessibility issues.
- Schedule periodic accessibility audits in CI/CD.

---

## 9. Internationalization (Optional)

- Ensure all user-facing text, ARIA labels, and feedback messages are localizable for future multi-language support.
- Use a library or framework for i18n if supporting multiple languages.
- Define how users select their preferred language in the UI.
- Define a fallback language and handling for untranslated content.
- Show fallback language or placeholder for untranslated content.

---

## 10. Performance

- Implement pagination or lazy loading if the kanji dataset is large to ensure smooth user experience.
- Show loading indicators and handle errors for paginated/lazy-loaded data.
- Define sorting/filtering strategies for paginated/lazy-loaded data.
- Ensure user progress is persisted across pages.
- Optimize queries and indexes for large datasets.

---

## 11. Monitoring and Analytics

- Add telemetry or logging for quiz usage, errors, and performance monitoring.
- Collect metrics such as quiz completion rates, error rates, and performance timings.
- Set thresholds for error/performance metrics to trigger alerts.
- Define alert recipients and incident response process (e.g., email, Slack, dashboard).
- Periodically review and adjust monitoring thresholds.
- Do not log or analyze sensitive user data.

---

## Next Steps

1. Scaffold the `UserKanjiProgress` Ash resource.
2. Implement the SRS logic module.
3. Build the Quiz LiveView interface.
4. Write integration and resource tests.
5. Style the UI with Tailwind CSS and oklch colors, maintaining design system consistency.
6. Add accessibility, error handling, and performance improvements.
7. Update documentation and ensure all user-facing text is localizable.
8. Add monitoring and analytics for quiz usage and errors.
9. Update `CHANGELOG.md` after each change.

---