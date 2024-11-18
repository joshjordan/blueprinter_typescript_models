# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.4]

### Added

- Support for skipping fields by setting `typescript_type: false` in field options

### Fixed

- Ensure all blueprints are loaded when running the rake task by adding Rails eager loading
- Improved model class lookup to search ObjectSpace for models with matching names when constantize fails
- Fixed type detection for aliased fields by using the original field name for schema lookup

### Changed

- Unified field type detection using a FieldInfo struct to reduce code duplication
- Changed default output directory to `app/javascript/types` to better align with Rails conventions
- Prefixed generated interface names with 'I' to follow TypeScript naming conventions (e.g., IUser)

## [0.1.3]

### Changed

- Updated required Ruby version to >= 2.7.0 while maintaining 3.0.6 as development version

## [0.1.2]

### Added

- Architecture and feature roadmap documentation

### Changed

- Improved Ruby version management and compatibility
- Relaxed Blueprinter version constraint for better Ruby 2.7 compatibility

## [0.1.1]

### Added

- Support for multiple Ruby versions in GitHub Actions

### Changed

- Switched to PostgreSQL for testing complex types
- Improved model class inference for TypeScript type generation
- Updated minimum Ruby version to 3.0.6
- Enhanced field and association handling using Blueprinter reflections API

### Fixed

- Tests -- first green version!
- Cleaned up debug output
- Fixed directory path in test

## [0.1.0]

### Added

- Initial release
- Support for generating TypeScript interfaces from Blueprinter blueprints
- Custom typescript_type field option for explicit type definitions
- Automatic type inference from database schema
- Rails integration via Railtie
- Configuration options for output directory
- Support for associations and array types
- Proper handling of nullable fields
- Rake task for generating TypeScript definitions
