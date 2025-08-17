# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.1] - 2024-08-17

### Fixed
- Fixed Channel reference in compile_css! method to use correct namespace (Compiler::Channel)

## [0.2.0] - 2024-08-17

### Added
- Production/Development mode separation - compiler automatically skips in production for better performance
- Persistent AST caching with JSON storage for improved performance between runs
- Dark mode helper method: `dark(bg: :gray, text: :white)`
- Responsive design helper: `at(:md, w: "1/2")`
- Style composition methods for better reusability:
  - `merge` / `+` - Combine styles
  - `with` - Override specific attributes
  - `except` - Remove specific attributes
- Comprehensive error handling throughout the compiler
- Production mode specs and development mode specs
- Stress tests for compiler edge cases
- StandardRB for code linting (replaced RuboCop)

### Changed
- Switched from RuboCop to StandardRB for more reasonable linting defaults
- Improved boolean value handling in the compiler
- Enhanced security with safeguards around eval() usage

### Fixed
- FileCompiler class name mismatch (renamed to FileParser)
- Configuration value handling to support both procs and strings
- AST node type handling for boolean literals (`:true` and `:false`)
- Cache invalidation on file changes
- Theme memoization not being cleared on reconfiguration

### Security
- Added validation for eval() usage to only allow simple literals and symbols
- Restricted eval() input patterns for safety

## [0.1.0] - 2024-07-28

- Initial release
