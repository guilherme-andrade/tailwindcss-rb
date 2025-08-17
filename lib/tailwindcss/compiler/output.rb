require "fileutils"

module Tailwindcss
  module Compiler
    class Output
      def add_entry(file_path:, classes:)
        file_path = absolute_path(file_path)
        return if classes.blank?

        path = output_file_path(file_path:)
        create_output_folder(file_path: path)

        path += ".classes"
        File.open(path, "wb") do |file|
          file << classes.join("\n")
        end
        File.delete(path) if File.empty?(path)
      end

      def compile_classes_dir
        dir = Tailwindcss.config.compiler.compile_classes_dir
        dir = dir.respond_to?(:call) ? dir.call : dir
        absolute_path(dir)
      end

      def create_output_folder(file_path:)
        dir_name = File.dirname(file_path)
        FileUtils.mkdir_p(dir_name)
      end

      def output_file_path(file_path:)
        content.each do |folder|
          if file_path.start_with?(folder)
            return File.join(compile_classes_dir, file_path.delete_prefix(folder.to_s))
          end
        end

        nil
      end

      def content
        content_config = Tailwindcss.config.content
        content_array = content_config.respond_to?(:call) ? content_config.call : content_config
        content_array.map { |path| absolute_path(path) }
      end

      def absolute_path(path)
        File.expand_path(path)
      end
    end
  end
end
