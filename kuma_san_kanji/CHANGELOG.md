# Changelog

## [Latest] - 2025-06-08

### ✅ DEPLOYMENT SUCCESS - Production Deployment to Fly.io

#### Application Status: LIVE and OPERATIONAL

- **URL**: <https://kuma-san-kanji.fly.dev>
- **Status**: ✅ Successfully deployed and running
- **Database**: ✅ SQLite3 with persistent volume storage
- **Migrations**: ✅ All database migrations applied successfully
- **Seeding**: ✅ Database seeded with kanji data
- **LiveView**: ✅ Phoenix LiveView connections working

### Production Issues Resolved

- ✅ Resolved database connectivity issues in production
- ✅ Fixed DATABASE_URL parsing in runtime.exs
- ✅ Configured SQLite3 adapter for Fly.io environment
- ✅ Ensured proper database initialization on deployment
- ✅ Application server now properly listening on 0.0.0.0:8080

### Technical Details

- **Platform**: Fly.io
- **Region**: London (lhr)
- **Database**: SQLite3 with encrypted volume
- **Server**: Bandit 1.7.0
- **Runtime**: Elixir/Phoenix with Ash Framework

### Database Schema

All migrations successfully applied:

- ✅ Initial tables (users, kanjis, pronunciations, meanings, examples)
- ✅ User kanji progress tracking
- ✅ Duplicate prevention constraints
- ✅ Review date formatting fixes
- ✅ Content domain tables (thematic groups, educational contexts, learning meta)

### Deployment Configuration

- Docker-based containerization
- Persistent volume for database storage
- Automatic migration and seeding on deploy
- Health checks and monitoring enabled

## June 14, 2025

### Project Compilation and Stability

- **FIXED**: Resolved persistent `ArgumentError: KumaSanKanji.Content is not a Spark DSL module` by correctly defining and referencing `KumaSanKanji.Content.Domain`.
- **FIXED**: Addressed various compilation warnings and errors related to domain and action definitions.
- **REFACTOR**: Centralized Ash actions within their respective domains (`KumaSanKanji.Content.Domain` and `KumaSanKanji.Domain`) instead of individual resources.
- **REFACTOR**: Updated seeder logic in `content_seeder.ex` and `content/seeds.ex` to use new domain actions and correct aliases, resolving syntax errors and removing unused code.
- **CONFIG**: Updated `config/config.exs` to correctly list `KumaSanKanji.Content.Domain` in `ash_domains`.
- **IMPROVED**: Achieved a clean `mix compile` with no errors or warnings.

## June 6, 2025

### Critical Spark DSL Module Fixes

- **FIXED**: Fixed KeyError for `:repetitions` not found in `%KumaSanKanji.Kanji.Kanji{}` struct
  - Fixed by updating `load_next_kanji` function to properly store the current progress record
  - Updated QuizLive template to reference `@current_progress.repetitions` instead of `@current_kanji.repetitions`
  - The error occurred because `repetitions` is a field of the UserKanjiProgress record, not the Kanji record
  - Fixed syntax errors in the QuizLive module file that were causing compiler errors

- **FIXED**: Fixed KeyError for current_kanji in QuizLive
  - Modified `load_kanji_data` in SRS Logic to explicitly select required fields
  - Updated QuizLive to extract kanji correctly from progress records
  - Fixed template references from `@current_kanji.kanji.character` to `@current_kanji.character`
  - Updated HTML template to handle the direct kanji structure instead of nested structure
  - Fixed functions that expect a direct kanji structure instead of a progress record wrapping a kanji
  - Updated functions `get_feedback_message` and `check_answer_correctness` to handle the kanji structure directly

- **FIXED**: Fixed KeyError for character field in ExploreLive
  - Modified error handling in `get_kanji_by_offset` to extract the kanji object from the list
  - The issue was that the `loaded_kanji` variable was a list containing one kanji object, not the object itself
  - Added pattern matching in the error handling block: `{:ok, [loaded_kanji]} = Kanji.get_by_id(...)`

- **FIXED**: Fixed undefined function error in ExploreLive with correct Ash filter syntax
  - Changed `Ash.Query.filter(field: value)` to `Ash.Query.do_filter([field: value])`
  - `filter` is a macro in Ash, not a function, requiring proper usage syntax
  - Fixed error: "function Ash.Query.filter/2 is undefined or private"

- **FIXED**: Removed pin operator (^) usage in Ash filter expressions across all resources
  - Pin operator cannot be used in Spark DSL expressions
  - Fixed filter expressions in ThematicGroup, KanjiThematicGroup, EducationalContext, KanjiUsageExample, KanjiLearningMeta, Kanji, and UserKanjiProgress resources
  - Changed `filter expr(field == ^arg(:value))` to `filter expr(field == arg(:value))`

- **FIXED**: Cross-domain reference issue in KanjiThematicGroup resource
  - Removed belongs_to :kanji relationship that referenced KumaSanKanji.Kanji.Kanji from different domain
  - Changed to use kanji_id UUID attribute to prevent circular dependencies
  - This resolves "not a Spark DSL module" compilation errors

- **FIXED**: Syntax errors with missing newlines between DSL sections
  - Fixed formatting issues that prevented proper DSL parsing
  - All Content domain resources now compile successfully

### Domain Architecture Improvements
- Added explicit aliases for Content domain resources to ensure proper loading order
- Added ChangeTracking extension to the Content domain for better audit capabilities
- Configured domain validation to be skipped in test environment for faster tests
- Reorganized resource loading order in Content domain based on dependency hierarchy
- Fixed resource references in seeds and LiveView modules

### Bug Fixes
- Fixed Ash resource compilation errors by ensuring proper module loading
- Fixed circular dependencies between domain modules

## June 13, 2025

### Added New Kanji Module Functions

- **Added `list_all/0` function** - New function to return all kanji with relationships loaded
- **Added `get_by_character/1` function** - New function to find kanji by character with relationships loaded
- Both functions load meanings, pronunciations, and example sentences
- Improved code organization with proper Ash Resource patterns

## June 12, 2025

### Enhanced Explore Page with Rich Contextual Information

- **Added thematic groups display** - Implemented UI section showing thematic groups (Numbers, Nature, etc.) for each kanji
- **Added educational context** - Displays grade level, age range, and curriculum information
- **Added learning tips** - Shows mnemonic hints, visual evolution, and stroke order tips
- **Added common words section** - Shows compound words using the kanji, their readings and meanings
- **Enhanced example sentences** - Better organized example sentences with Japanese and translations
- **Improved data loading** - Enhanced the `get_kanji_by_offset` function to fetch all contextual data
- **UI enhancements** - Styled all new sections with Tailwind CSS using the app's color scheme
- **Added responsive design** - Ensured all new sections adapt well to different screen sizes

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
