# frozen_string_literal: true

require "fileutils"

module BlueprinterTypescriptModels
  class Generator
    class << self
      def generate_all(blueprints_path = nil)
        output_dir = if BlueprinterTypescriptModels.configuration.output_dir.start_with?("/")
                       BlueprinterTypescriptModels.configuration.output_dir
                     else
                       File.join(Dir.pwd, BlueprinterTypescriptModels.configuration.output_dir)
                     end
        FileUtils.mkdir_p(output_dir)

        if blueprints_path
          # Generate from files in directory
          Dir[File.join(blueprints_path, "**/*.rb")].each do |blueprint_file|
            require blueprint_file
            blueprint_class = File.basename(blueprint_file, ".rb").camelize.constantize
            generate_for_blueprint(blueprint_class, output_dir) if blueprint_class < Blueprinter::Base
          end
        else
          # Generate from already loaded blueprints
          ObjectSpace.each_object(Class).select do |klass|
            klass < Blueprinter::Base
          end.each do |blueprint_class|
            generate_for_blueprint(blueprint_class, output_dir)
          end
        end
      end

      private

      def generate_for_blueprint(blueprint_class, output_dir)
        interface_name = "I#{blueprint_class.name.demodulize.gsub('Blueprint', '')}"
        output_path = File.join(output_dir, "#{interface_name}.d.ts")
        content = generate_interface(interface_name, blueprint_class)
        File.write(output_path, content)
      end

      def generate_interface(interface_name, blueprint_class)
        fields = collect_fields(blueprint_class)
        associations = collect_associations(blueprint_class)

        [
          "// Generated by blueprinter_typescript_models",
          "// Do not edit this file directly",
          "",
          *generate_imports(associations),
          "",
          "export interface #{interface_name} {",
          *fields.map { |name, type| "  #{name}: #{type};" },
          *associations.map { |name, type| "  #{name}: #{type};" },
          "}",
          ""
        ].join("\n")
      end

      def collect_fields(blueprint_class)
        fields = blueprint_class.reflections[:default].fields
        fields.each_with_object({}) do |(display_name, field), result|
          if (type = TypeMapper.map_field(display_name, blueprint_class))
            result[display_name] = type
          end
        end
      end

      def collect_associations(blueprint_class)
        blueprint_class.reflections[:default].associations.transform_values do |assoc|
          name = "I#{assoc.blueprint.name.demodulize.gsub('Blueprint', '')}"
          assoc.options[:blueprint_collection] ? "#{name}[]" : name
        end
      end

      def generate_imports(associations)
        return [] if associations.empty?

        associations.values.uniq.map do |type|
          base_type = type.gsub("[]", "")
          %(import type { #{base_type} } from "./#{base_type}";)
        end
      end
    end
  end
end
