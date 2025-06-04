# Plan for Implementing an SRS-Based Quiz Review System

## Overview

This document outlines the plan to implement a Spaced Repetition System (SRS) based quiz review feature for the KumaSanKanji application. The system will leverage kanji data from the `references` folder and provide personalized, adaptive review sessions for authenticated users. All implementation steps will follow the provided coding, security, testing, and styling instructions.

---

## 1. Ash Resource: UserKanjiProgress

**Purpose:**  
Track each user's review state for each kanji, including:
- User ID (authenticated)
- Kanji character
- Next review date
- Interval (days)
- Ease factor (for SRS)
- Repetitions
- Last result

**Security:**  
- Only authenticated users can access/modify their own progress.
- All queries will be parameterized.
- No sensitive data will be exposed.

**Testing:**  
- Use Ash's test resources and built-in utilities for isolated resource tests.

---

## 2. Quiz LiveView

**Purpose:**  
- Present kanji for review based on SRS schedule.
- Accept and validate user answers.
- Provide immediate feedback.
- Update SRS state according to user performance.

**Security:**  
- Validate and sanitize all user input.
- Escape all user-facing content to prevent XSS.
- Require authentication for all quiz actions.

**Styling:**  
- Use Tailwind CSS for all UI elements.
- Use oklch for all color values.

---

## 3. SRS Logic

**Purpose:**  
- Implement the SM-2 algorithm (or similar) to determine the next review date and interval for each kanji based on user performance.

**Security:**  
- All updates are parameterized and authenticated.

---

## 4. Integration and Resource Tests

**Purpose:**  
- Cover the quiz flow, answer validation, and SRS state updates.
- Use Ash's test resources for resource tests.
- Ensure all tests are isolated and do not depend on database state.

---

## 5. Change Logging

**Purpose:**  
- Log all changes in `CHANGELOG.md` with the date and a brief description.

---

## 6. Security Review

- Validate all user input.
- Escape all user-facing content.
- Use parameterized queries for all data access.
- Require authentication and authorization for all user-specific data.
- Use HTTPS for all communications.

---

## Next Steps

1. Scaffold the `UserKanjiProgress` Ash resource.
2. Implement the SRS logic module.
3. Build the Quiz LiveView interface.
4. Write integration and resource tests.
5. Style the UI with Tailwind CSS and oklch colors.
6. Update `CHANGELOG.md` after each change.

---
