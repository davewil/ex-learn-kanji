# Changelog

## June 12, 2025

- Resolved `WithClauseError` in `KumaSanKanji.Accounts.User`'s `sign_up` action.
- Corrected the return type of the `validate_password_length/2` custom change function to return the changeset directly, or the changeset with an error, instead of an `{:ok, changeset}` tuple.
- Updated the `hash_password/2` custom change function to correctly check for changeset validity using `changeset.valid?` before proceeding with password hashing and to return the changeset directly.

## June 3, 2025

### Additional Authentication Fixes

- Redesigned authentication approach to separate concerns between User resource and Auth module
- Simplified User.login action to only focus on retrieving user data with hashed_password
- Enhanced Auth.login function to handle password verification separately from data retrieval
- Added comprehensive handling for various return patterns (nil, empty list, single user, list of users)
- Fixed incorrect password validation by moving password checking logic to Auth module
- Improved error messages to be more consistent and user-friendly
- Eliminated DSL errors by using simpler action configurations in Ash resources
- Resolved compilation issues with manual, change, and validate functions

## June 2, 2025

### Authentication Fixes

- Fixed `validate_password_length/2` custom change function to properly validate password length without using undefined `validate_change/3` function
- Fixed `hash_password/2` custom change function to implement proper password hashing using Pbkdf2 directly
- Added missing `validate_password_on_login/2` function for the login action to authenticate users properly
- Enhanced error handling in password-related functions
- Fixed login action to properly use Ash.Query.load instead of the build preparator, which was causing errors in the tests
- Simplified action preparation code to avoid parameter manipulation issues
- Fixed UserLiveAuth to safely handle flash messages by checking if the socket supports them
- Updated UserAuth plug to fetch flash before using it to avoid ArgumentError
- Fixed get_user function to properly return error when user doesn't exist

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

## June 3, 2025
- Fixed a compilation error in `signup_live.ex` by removing an invalid code block delimiter (```), which was causing a syntax error.
- Verified successful compilation with `mix compile`.

## June 11, 2025

- Fixed Ash custom change function registration for password validation: now uses `&__MODULE__.validate_password_length/2` in the `sign_up` action. This resolves all related test failures.
- Fixed Ash custom change function registration for password hashing: now uses `&__MODULE__.hash_password/2` in the `sign_up` action, and the `hash_password/2` function now accepts two arguments. This resolves all related test failures.
- Corrected `UndefinedFunctionError` for `validate_password_length` and `hash_password` custom changes in `KumaSanKanji.Accounts.User` resource by using `&__MODULE__.function_name/2` syntax and ensuring correct function arity.
- Refactored the `login` action in `KumaSanKanji.Accounts.User`:
    - Explicitly defined the `:email` argument.
    - Replaced `prepare :validate_password` with a `build` preparer that loads `:hashed_password`, passes the action's `:password` argument into a changeset, and then applies a new `validate_password_on_login/2` change function.
    - The `validate_password_on_login/2` function correctly compares the input password with the stored hash and adds an error to the changeset if verification fails.
    - Removed the old `validate_password/1` function.

## 2024-06-09
- Fixed custom Ash validation function `validate_password_length/2` to return `{:ok, changeset}` or `{:error, [error]}` as required by Ash, resolving `WithClauseError` in authentication tests.
- Ensured secure input validation and error handling for user sign up.
- Updated Ash DSL to use fully qualified function references for custom validation and change functions.
- Removed unused validation function for clarity.
