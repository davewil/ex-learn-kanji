## Operator Instructions

- When asked to fix code, first explain the problems found.
- When asked to generate tests, first explain what tests will be created.
- When making multople changes, explain each change before implementing it.
- Use PowerShell for Windows and Bash for Linux/MacOS.

## Security

- Check the code for vulnerabilities, such as SQL injection, XSS, and CSRF after each change.
- Ensure that sensitive data is not exposed in the code or logs.
- Validate user inputs to prevent security issues.
- Use secure coding practices, such as parameterized queries for database access.
- Ensure that authentication and authorization are properly implemented.
- Use HTTPS for all communications to protect data in transit.

## Using Ash Framework

- [Using Ash Framework](instructions/ash-rules.instructions.md)

## Change logging

- Each time you generate code, note the changes in changelog.md.
- Include the date and a brief description of the changes made.

## Testing requirements

- Ensure that all new code is covered by tests.
- Add integration tests for new features.
- [Use Ash's test resources](https://hexdocs.pm/ash/3.5.14/test-resources.html) to create tests for Ash resources.
- Use Ash's built-in testing utilities to verify resource behavior.
- Ensure that tests are isolated and do not depend on the state of the database.

## CSS requirements
- Use Tailwind CSS for styling.
- Use oklch for colors.