# Blueprinter TypeScript Models

Generate TypeScript interfaces from Ruby's Blueprinter blueprints automatically. This gem integrates with Blueprinter to create TypeScript type definitions that match your serializer outputs, supporting custom type annotations and falling back to database schema types.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'blueprinter_typescript_models'
```

And then execute:

```bash
$ bundle install
```

## Usage

### Basic Usage

The gem automatically adds TypeScript type generation capabilities to your Blueprinter serializers. Use the `typescript_type` option to explicitly define TypeScript types for fields:

```ruby
class UserBlueprint < Blueprinter::Base
  identifier :id
  field :name
  field :email
  field :profile_picture, typescript_type: "string | null"
  field :settings, typescript_type: "Record<string, unknown>"
  association :posts, blueprint: PostBlueprint, blueprint_collection: true
end
```

### Generating TypeScript Interfaces

Run the provided rake task to generate TypeScript interface files:

```bash
$ rails typescript:generate
```

This will create TypeScript interface files in `app/javascript/types/` (following Rails JavaScript organization standards) that match your Blueprinter definitions:

```typescript
// Generated by blueprinter_typescript_models
// Do not edit this file directly

import type { Post } from "./Post";

export interface User {
  id: number;
  name: string;
  email: string;
  profile_picture: string | null;
  settings: Record<string, unknown>;
  posts: Post[];
}
```

### Configuration

You can configure the output directory for TypeScript files. By default, files are generated in `app/javascript/types` following Rails conventions, but you can customize this:

```ruby
# config/initializers/blueprinter_typescript_models.rb
BlueprinterTypescriptModels.configure do |config|
  config.output_dir = "custom/path/to/types" # default is "app/javascript/types"
end
```

### Type Inference

The gem automatically infers TypeScript types from your database schema when `typescript_type` is not specified:

- `string` for `:string`, `:text`, `:uuid`, `:citext`
- `number` for `:integer`, `:bigint`, `:decimal`, `:float`
- `boolean` for `:boolean`
- `Date` for `:datetime`, `:date`, `:timestamp`
- `Record<string, unknown>` for `:jsonb`, `:json`
- `T[]` for array columns (PostgreSQL)
- `unknown` for unrecognized types

Nullable database columns automatically get union types with `null`.

### FAQ

#### How do I specify the type for a field created by `identifier`?

If the gem cannot infer the identifier's type from the database schema, you can override the `identifier` method in a base class or module for your blueprints. Here's how to do it:

```ruby
module BlueprintBase
  def self.identifier(name = nil, options = {})
    super
    typescript_type = options[:typescript_type] || :string
    view_collection[:identifier].fields.values.each { |v| v.options[:typescript_type] = typescript_type }
  end
end

# Then in your blueprints:
class UserBlueprint < Blueprinter::Base
  extend BlueprintBase

  identifier :id, typescript_type: "string"  # Now typescript_type option works!
  # ... rest of your blueprint
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/joshjordan/blueprinter_typescript_models.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
