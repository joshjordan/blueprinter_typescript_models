# frozen_string_literal: true

module BlueprinterTypescriptModels
  class TypeMapper
    FieldInfo = Struct.new(:model_class, :type, :array, :nullable)

    class << self
      def map_field(display_name, blueprint_class)
        field = blueprint_class.reflections[:default].fields[display_name]
        return "unknown" unless field

        if field.options.key?(:typescript_type)
          return nil unless field.options[:typescript_type]

          field.options[:typescript_type]
        elsif (field_info = infer_field_info(field.name, blueprint_class))
          map_database_type(field_info.type, field_info.array, field_info.nullable)
        else
          "unknown"
        end
      end

      private

      def infer_field_info(field_name, blueprint_class)
        # 1. Check for explicit model_class method
        if blueprint_class.respond_to?(:model_class)
          field_info = detect_field_info(blueprint_class.model_class, field_name)
          return field_info if field_info
        end

        # 2. Try to infer from blueprint name
        model_name = blueprint_class.name.demodulize.sub(/Blueprint$/, "")
        begin
          model_class = model_name.constantize
          field_info = detect_field_info(model_class, field_name)
          field_info if field_info
        rescue NameError
          # 3. Search ObjectSpace for matching class name and valid schema
          matching_classes = ObjectSpace.each_object(Class).select do |klass|
            klass.name.split("::").last == model_name
          rescue StandardError
            nil
          end

          matching_classes.each do |model_class|
            field_info = begin
              detect_field_info(model_class, field_name)
            rescue StandardError
              nil
            end
            return field_info if field_info
          end

          # 4. If that fails too, try parent blueprints
          infer_from_parent_blueprint(field_name, blueprint_class)
        end
      end

      def detect_field_info(model_class, field_name)
        return nil unless model_class&.name

        # Handle ActiveRecord models
        if model_class.respond_to?(:columns_hash) && (column = model_class.columns_hash[field_name.to_s])
          return FieldInfo.new(model_class, column.type, column.array?, column.null)
        end

        # Handle Neo4j models
        if model_class.respond_to?(:declared_properties) && (property = model_class.declared_properties[field_name])
          type = property.type ? property.type.name.split("::").last.downcase : "string"
          # For Neo4j, assume null is always true and array is always false
          return FieldInfo.new(model_class, type, false, true)
        end

        nil
      end

      def infer_from_parent_blueprint(field_name, blueprint_class)
        return nil if blueprint_class == Blueprinter::Base
        return nil unless blueprint_class.superclass

        parent_class = blueprint_class.superclass
        infer_field_info(field_name, parent_class)
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
