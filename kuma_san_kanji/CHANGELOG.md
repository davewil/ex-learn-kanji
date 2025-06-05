# Changelog

## June 5, 2025 (Update 3)

### Fixed Compiler Warnings and Improved Codebase Quality

- **Fixed quiz session loading** - Fixed undefined module function `KumaSanKanji.Api.load/2` in `quiz/session.ex` by using Ash.Query for loading relationships
- **Improved error handling** - Enhanced error handling in the Kanji loading process with proper exception messaging
- **Code structure improvements** - Fixed syntax and spacing issues in the `session.ex` file
- **Enhanced code clarity** - Fixed indentation and structure in multiple files

## June 5, 2025 (Update 2)

### Fixed SRS Reset ArgumentError

- **Fixed critical issue** - Fixed `ArgumentError` occurring when clicking the "Reset Quiz Progress" button in the web UI
- **Enhanced error handling** - Added comprehensive error handling and logging throughout the SRS reset flow
- **Debug-friendly code** - Added detailed logging to help identify issues in the reset process
- **Robust exception handling** - Added try/rescue blocks to properly catch and report exceptions
- **Improved documentation** - Better comments explaining the SRS reset process and its components

## June 5, 2025

### Enhanced Debug Reset Functionality

- **Enhanced reset functionality** - Improved the `reset_user_progress` function to not only clear progress but also set up an initial review list
- **Added configuration options** - Added options to specify number of kanji to initialize and whether to make them due immediately
- **Improved error handling** - Better error handling and logging in SRS reset logic
- **Enhanced UI for dev tools** - Made the reset button more visually distinct as a debugging tool
- **Better user feedback** - Enhanced messaging to show how many kanji were initialized for review
- **Fixed dev mode issues** - Ensured the reset button properly appears in development mode

## June 4, 2025 (Part 2)

### Test Fixes and Authentication Improvements

- **Fixed Ash.Query macro usage** - Added `require Ash.Query` statements where macros are used
- **Fixed LiveView flash handling** - Updated user authentication to use redirect with flash options instead of direct assignment
- **Improved error handling** - Added proper pattern matching for login return values
- **Code cleanup** - Fixed unused variables and imports in test modules
- **Enhanced maintainability** - Removed unnecessary code in user_live_auth module

## June 4, 2025 (Part 1)

### Ash Framework Form Integration Fixed

- **Fixed AshPhoenix.Form integration** - Resolved compilation errors with undefined `for_change/2` function
- **Updated signup form to use proper AshPhoenix.Form API** - Using `for_create/3` and converting to Phoenix forms with `to_form/1`
- **Fixed form protocol implementation** - Resolved Access behaviour error by wrapping AshPhoenix.Form in Phoenix form
- **Removed deprecated function calls** - Cleaned up unused `format_error` and old changeset-based approach
- **Improved form validation** - Proper integration between AshPhoenix.Form validation and Phoenix LiveView

## June 10, 2025

### Authentication Security Improvements

- Enhanced Auth module with better token verification and user session management
- Added session timeout/expiration handling (7-day limit)
- Improved password validation with stronger requirements
- Added email validation on signup
- Implemented protection against session fixation attacks
- Created comprehensive test suite for all authentication modules

### User Experience Improvements

- Updated login and signup forms to match application design system
- Improved feedback for form validation errors
- Enhanced homepage to personalize welcome message for logged-in users
- Improved UI consistency with font-katakana class throughout forms
- Added Japanese text to auth forms for better visual consistency

### Testing Improvements

- Added tests for Auth module (login, user retrieval, session creation)
- Added tests for UserAuth module (authentication flows, session management)
- Added tests for UserLiveAuth module (LiveView authentication hooks)
- All tests follow Ash's testing patterns for consistent test isolation

### Security

- Implemented proper CSRF protection for authentication endpoints
- Added validation for user inputs to prevent security issues
- Improved password requirements (minimum 8 chars, must include a number)
- Added secure session management with token expiration
- Protection against session fixation by regenerating session on login/logout

## June 3, 2025

### Styling Improvements

- Added custom styling based on README requirements:
  - Implemented font styling with angular, katakana-like fonts
  - Created color palette blending Akihabara neon colors and cherry blossom themes
  - Added custom SVG mascots (Tono-kun and Hime-chan)
- Updated Tailwind configuration:
  - Added neon colors (blue, pink, purple, green, yellow) in oklch color space
  - Added sakura colors (light, default, dark, blossom, white) in oklch color space
  - Added katakana-style fonts

### Compliance Updates

- Modified color scheme to use oklch color space as required by project guidelines
- Updated project to adhere to development guidelines in copilot-instructions.md
- Ran test coverage report to identify areas needing additional tests
- Current test coverage is at 34.29% (target: 90%)
- Enhanced UI elements:
  - Styled navigation bar with neon effect
  - Styled Explore page with dark theme and neon accents
  - Added consistent styling for buttons, cards, and text elements
  - Created themed variants for on/kun readings
- Created mascot SVG illustrations:
  - Tono-kun (male black and tan shiba inu)
  - Hime-chan (female red shiba inu with bow accessory)

## June 2, 2025

### Styling Refinements

- Removed neon colors throughout the application as requested
- Updated color palette to use more subdued, elegant oklch colors
- Replaced "accent" colors (blue, pink, purple, green, yellow) with softer variants
- Enhanced typography with consistent Katakana-inspired font usage
- Improved overall UI consistency with a lighter color theme
- Fixed kanji data display by seeding the development database
- Applied consistent styling to both home page and explore page
- Updated button styles across all pages to match new design system

### Test Improvements

- Fixed implementation for all test files:
  - `explore_live_test.exs`: Now uses seeded data instead of creating test records
  - `kanji_test.exs`: Modified to work with pre-seeded database
  - `example_sentence_test.exs`: Fixed to work properly with database constraints
- Properly configured database connection handling in tests:
  - Updated `conn_case.ex` to ensure database sandbox is set up correctly
  - Modified `test_helper.exs` to initialize Ecto sandbox mode
- All tests now pass successfully with the seeded test database

### Bug Fixes

- Fixed database connection issues in LiveView tests
- Eliminated ownership errors by properly configuring Ecto Sandbox mode
- Simplified test setup for LiveView tests to use existing data
- Updated tests to be resilient to database state changes
- Removed warnings by fixing unused aliases in test files
- Fixed compiler warnings by prefixing unused variables with underscore

### Added (Initial Database Seed)

- Seeded development database with initial kanji data including:
  - Basic kanji characters (水, 火, 木, 山, 川, 日, 月, 人)
  - Associated meanings, pronunciations, and example sentences for each kanji
- Set up test database with initial data for consistent testing
- Created script to reset and seed databases (reset_and_seed_dev.exs)
- Added comprehensive tests for:
  - Kanji resource basic operations
  - Meaning resource and relationships
  - Pronunciation resource and relationships
  - ExampleSentence resource and relationships
  - ExploreLive LiveView functionality

### Fixed

- Updated test files to handle pre-seeded database:
  - Modified KanjiTest to work with existing data instead of assuming empty database
  - Updated ExampleSentenceTest to safely coexist with seeded data
  - Fixed by_offset tests to check relative ordering instead of absolute positions
  - Corrected count_all tests to validate incremental increases instead of absolute values
- Fixed relationship tests to address foreign key constraints
- Made ExploreLive tests more resilient to database state changes

### Security

- No security issues identified in database seeding implementation
- All database interactions use Ash framework's built-in security mechanisms for database access
- No SQL injection vulnerabilities present as queries use parameterized inputs

### Testing

- All tests now pass successfully with the seeded databases
- Test database correctly resets between test runs
- Fixed test isolation issues by using proper test setup patterns

### Future Work

- Increase test coverage for the ExploreLive module (currently at 0%)
- Add tests for Auth-related modules
- Add tests for PageController and other application components
- Implement end-to-end testing

## 2025-06-03
- Fixed issue with `mix deps.get` by running the command in the correct directory (`kuma_san_kanji/`).

## 2025-06-04
- Fixed compilation error in `KumaSanKanji.Accounts.User` by replacing invalid `manual :login` action with a generic Ash action using `action :login, :struct do ... end` and a `run` block, following Ash documentation.
- Re-seeded the database using priv/repo/seeds.exs.

## 2025-06-05
- Enhanced duplicate kanji progress merge logic in `fix_duplicates.exs` to combine all SRS fields (interval, ease_factor, repetitions, review dates, last_result) for accurate user progress migration.
- Fixed FunctionClauseError in quiz stats: next_review_date is now normalized to NaiveDateTime for all types (string, DateTime, NaiveDateTime) in SRS logic.
- Fixed Ash filter error in due_for_review by removing unsupported strftime and using direct datetime comparison. Quiz page now loads due kanji correctly.
- Added a dev-only 'Reset Quiz Progress' button to the quiz page and supporting backend logic for easy testing. Button only appears in dev mode and securely deletes all user progress for the current user.

## 2025-06-10
- Added detailed error logging and improved error surfacing in quiz_live.ex to help diagnose quiz page errors. Added try/rescue in session helpers and user-friendly error messages with debug info in non-production.

## [Unreleased] - 2024-06-11

- Fixed unused variable warning in `restore_session_if_exists/2` by renaming `user_id` to `_user_id` in the nil clause.

- Ensured all div tags in the 'active quiz state' block of `quiz_live.html.heex` are properly closed to resolve template parse error.
