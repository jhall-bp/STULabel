# General

- When fixing issues, always look at the bigger picture for ways to make meaningful improvements - you must avoid safe, additive changes.
- Before adding complexity for a speculative or vanishingly unlikely race or security edge case, explain the concrete failure mode, likelihood, and complexity cost to the user and get their buy-in. Do not silently expand scope for theoretical robustness.
- Always keep performance in the forefront of your mind
- Use the Xcode MCP exclusively for all Xcode-related operations, including building, testing, running, debugging, and managing projects. Never invoke Xcode or its tooling via the command line (e.g., `xcodebuild`, `xcrun`, `swift build`, or `simctl`). If the Xcode MCP cannot perform an operation, report the limitation rather than falling back to CLI tools.

# Tests

- Write all new tests in Swift using the new Testing framework where possible
