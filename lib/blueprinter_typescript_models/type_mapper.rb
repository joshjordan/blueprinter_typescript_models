# frozen_string_literal: true

module BlueprinterTypescriptModels
  class TypeMapper
    class << self
      def map_field(field, blueprint_class)
        return field.options[:typescript_type] if field.options[:typescript_type]

        if (model_class = associated_class(blueprint_class))
          map_from_schema(field.name, model_class)
        else
          "unknown"
        end
      end

      private

      def associated_class(blueprint_class)
        return unless blueprint_class.respond_to?(:model_class)
        
        blueprint_class.model_class
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
