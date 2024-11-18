# TODO

## Architecture

The gem will introduce an abstract Interface Definition Layer (IDL) that serves as a unified representation of TypeScript interfaces and their associated metadata. This abstraction provides:

- A language-agnostic representation of interface definitions, validations, and metadata
- A plugin system for multiple input sources (Blueprinter, ActiveModel::Serializers, OJ, ActiveRecord, etc.)
- Support for custom interface definitions directly in Ruby code
- A centralized location for validation rules, type constraints, and documentation
- The foundation for generating various outputs (TypeScript interfaces, Zod schemas, model classes)
- Potential integration with RBS as it gains adoption, leveraging it as an intermediary interface definition layer since models and serializers will increasingly provide RBS type definitions by default

This architecture enables the gem to be serializer-agnostic while maintaining a consistent output format and feature set across different input sources.

## Features

- [ ] Add support for generating Zod schemas alongside TypeScript interfaces for runtime validation
- [ ] Add support for generating TypeScript enums from Ruby enums (e.g. from ActiveRecord::Enum)
- [ ] Add watch mode that regenerates types when blueprint files change
- [ ] Add support for generating TypeScript union types from polymorphic associations
- [ ] Add ability to generate documentation comments from Ruby comments above fields
- [ ] Add support for generating TypeScript utility types (Pick, Omit, etc.) based on Blueprinter views
- [ ] Add support for generating TypeScript types for nested JSON columns based on JSON schema definitions
- [ ] Add validation rules transfer (e.g. from ActiveRecord validations to TypeScript type constraints)
- [ ] Generate TypeScript interfaces and Zod schemas from Rails strong parameters
- [ ] One-time generation of TypeScript model classes that implement interfaces
  - Classes provide a foundation for business logic and methods
  - Generated once as starting points, then maintained manually
  - Interfaces continue to update with server changes
  - Include basic CRUD operations and API integration
- [ ] Give a way to specify the model class directly for a Blueprint. This may also be a good way to solve the problem of specifying a specific type for identifier fields. Just a general option for Blueprints?
- [ ] Add support for opting out of type generation for specific blueprints (e.g. abstract base blueprints like ApplicationBlueprint)

## Rails Integration Improvements

### Asset Pipeline Integration

- [ ] Add automatic type generation during asset compilation in development
- [ ] Integrate with asset preprocessors for JavaScript/TypeScript files

### Development Workflow

- [ ] Add file watcher for blueprint files with automatic regeneration
- [ ] Add Spring integration for faster development reloading
- [ ] Add Rails generator hooks for automatic type generation after model creation

### Build Process Integration

- [ ] Add Webpacker/esbuild integration hooks
- [ ] Add support for different output paths based on build environment
- [ ] Add configuration options for controlling when types are generated
