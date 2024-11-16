# frozen_string_literal: true

module BlueprinterTypescriptModels
  class TypeMapper
    class << self
      def map_field(field_name, blueprint_class)
        field = blueprint_class.reflections[:default].fields[field_name]
        return "unknown" unless field

        if field.options[:typescript_type]
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
        return "unknown" unless model_class.respond_to?(:columns_hash)

        column = model_class.columns_hash[field_name.to_s]
        return "unknown" unless column

        map_database_type(column)
      end

      def map_database_type(column)
        base_type = case column.type
                    when :string, :text, :uuid, :citext
                      "string"
                    when :integer, :bigint, :decimal, :float
                      "number"
                    when :boolean
                      "boolean"
                    when :datetime, :date, :timestamp
                      "Date"
                    when :jsonb, :json
                      "Record<string, unknown>"
                    else
                      "unknown"
                    end

        # Handle array types (PostgreSQL array columns)
        type = column.array? ? "#{base_type}[]" : base_type

        # Add null union type if the column is nullable
        column.null ? "#{type} | null" : type
      end
    end
  end
end
