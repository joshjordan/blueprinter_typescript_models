# frozen_string_literal: true

module BlueprinterTypescriptModels
  class TypeMapper
    class << self
      def map_field(field_name, blueprint_class)
        field = blueprint_class.reflections[:default].fields[field_name]
        return "unknown" unless field

        if field.options.key?(:typescript_type)
          return nil unless field.options[:typescript_type]

          field.options[:typescript_type]
        elsif (model_class = infer_model_class(blueprint_class))
          map_from_schema(field_name, model_class)
        else
          "unknown"
        end
      end

      private

      def infer_model_class(blueprint_class)
        # 1. Check for explicit model_class method
        return blueprint_class.model_class if blueprint_class.respond_to?(:model_class)

        # 2. Try to infer from blueprint name
        model_name = blueprint_class.name.demodulize.sub(/Blueprint$/, "")
        begin
          model_name.constantize
        rescue NameError
          # 3. If that fails, try parent blueprints
          infer_from_parent_blueprint(blueprint_class)
        end
      end

      def infer_from_parent_blueprint(blueprint_class)
        return nil if blueprint_class == Blueprinter::Base
        return nil unless blueprint_class.superclass

        parent_class = blueprint_class.superclass
        infer_model_class(parent_class)
      end

      def map_from_schema(field_name, model_class)
        # Handle ActiveRecord models
        if model_class.respond_to?(:columns_hash) && (column = model_class.columns_hash[field_name.to_s])
          return map_database_type(column.type, column.array?, column.null)
        end

        # Handle Neo4j models
        if model_class.respond_to?(:declared_properties) && (property = model_class.declared_properties[field_name])
          type = property.type ? property.type.name.split("::").last.downcase : "string"
          # For Neo4j, assume null is always true and array is always false
          return map_database_type(type, false, true)
        end

        "unknown"
      end

      def map_database_type(field_type, is_array = false, is_null = true)
        base_type = case field_type.to_s
                    when "string", "text", "uuid", "citext"
                      "string"
                    when "integer", "bigint", "decimal", "float"
                      "number"
                    when "boolean"
                      "boolean"
                    when "datetime", "date", "timestamp"
                      "Date"
                    when "jsonb", "json"
                      "Record<string, unknown>"
                    else
                      "unknown"
                    end

        # Handle array types
        type = is_array ? "#{base_type}[]" : base_type

        # Add null union type if nullable
        is_null ? "#{type} | null" : type
      end
    end
  end
end
