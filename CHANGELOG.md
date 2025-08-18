# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.0] - 2024-08-18

### Added
- Magic comment support with `@tw-whitelist` directive for explicit class inclusion
- Ability to whitelist Tailwind classes that can't be extracted via static analysis
- Support for magic comments in both Ruby (.rb) and ERB (.erb) files
- Comprehensive documentation in MAGIC_COMMENTS.md

### Changed
- File classes extractor now combines AST-extracted classes with magic comment classes
- This is a minor version bump as it adds new functionality

## [0.4.3] - 2024-08-18

### Fixed
- Fixed rake tasks not loading environment/configuration in non-Rails projects
- Tasks now work correctly with Rails apps, Ruby gems/engines, and standalone projects
- Added automatic environment loading with fallback to common config file locations
- Improved task output with detailed progress information

### Added
- Added RAKE_TASKS.md documentation for using rake tasks in different contexts
- Tasks now show extraction results and output file information

## [0.4.2] - 2024-08-18

### Added
- Added `extract_classes!` method to force class extraction in production mode
- Added Rake tasks for easier compilation (`tailwindcss:extract`, `tailwindcss:compile`, `tailwindcss:watch`)
- Added documentation for production mode usage

### Fixed
- Fixed `color_scheme_token` helper to handle integer inputs (was causing `undefined method to_sym for Integer` errors)
- Improved production mode workflow for component libraries

## [0.4.1] - 2024-08-18

### Fixed
- Fixed ActionCable broadcast error when cable configuration is not properly loaded
- Added early return when ActionCable.server.config.cable is nil to prevent fetch errors
- Improved compatibility with different Rails versions and ActionCable configurations
- Better error handling for missing or misconfigured cable.yml

## [0.4.0] - 2024-08-18

### Added
- Comprehensive Tailwind CSS configuration options support:
  - `darkMode` - Configure dark mode strategy ('media', 'class', or false)
  - `important` - Mark all utilities as !important (boolean or selector string)
  - `separator` - Customize separator character for modifiers
  - `safelist` - Array of classes to always include in CSS
  - `blocklist` - Array of classes to exclude from CSS
  - `presets` - Array of preset configurations
  - `plugins` - Array of Tailwind plugins
  - `corePlugins` - Enable/disable core plugins
- Proper configuration passing to Tailwind CLI via temporary config files
- Comprehensive integration test suite for the compiler
- Test components and ERB templates for Rails integration testing
- Ruby version compatibility for >= 2.5.0

### Changed
- Parser gem dependency now supports older Ruby versions (>= 2.5)
- Improved `compile_css!` method to properly pass all Ruby configuration to Tailwind CLI
- Enhanced glob pattern handling in Runner and Output classes

### Fixed
- Fixed prefix duplication issue where classes were being extracted with prefix already applied
- Fixed Runner not creating .classes files due to glob pattern handling issues
- Fixed Output class to properly handle glob patterns in content paths
- Fixed compile_css! not passing configuration to Tailwind CLI
- Removed .gem files from repository and added to .gitignore

## [0.3.2] - 2024-08-17

### Added
- Dummy Rails application for integration testing in `spec/dummy_rails_app/`
- Integration tests for ActionCable, asset pipeline, and compiler
- Rails as development dependency for testing
- Support for Rails 6.0+ (was previously Rails 7.0+)

### Fixed
- ActionCable logger configuration for multiple Rails versions (6.0, 6.1, 7.0, 7.1+)
- Works with both `ActionCable.server.logger=` (Rails 6.x/7.0) and `ActionCable.server.config.logger=` (Rails 7.1+)

## [0.3.1] - 2024-08-17

### Fixed
- Fixed NoMethodError when ActionCable.server.logger is nil
- Added safe logging methods (log_debug, log_info, log_warn, log_error)
- Channel.broadcast_css_changed now handles errors gracefully
- Logger initialization is now more robust

## [0.3.0] - 2024-08-17

### Added
- New `resolve_setting` helper method for cleaner configuration value resolution
- Separate `assets_path` and `output_file_name` configuration options (replaces single `output_path`)

### Changed
- **BREAKING**: Configuration now uses `compiler.assets_path` and `compiler.output_file_name` instead of `compiler.output_path`
- Channel broadcasts proper asset URLs (Rails asset_url when available, relative path otherwise)
- Refactored all configuration resolution to use consistent `resolve_setting` method

### Fixed
- Fixed undefined method `vite_asset_path` error in Compiler::Channel
- Removed unnecessary AssetHelper dependency from Channel class
- Channel now broadcasts web-accessible asset paths instead of file system paths

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
