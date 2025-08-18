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
        dir = Tailwindcss.resolve_setting(Tailwindcss.config.compiler.compile_classes_dir)
        absolute_path(dir)
      end

      def create_output_folder(file_path:)
        dir_name = File.dirname(file_path)
        FileUtils.mkdir_p(dir_name)
      end

      def output_file_path(file_path:)
        # For each content pattern, find the base directory
        content_base_dirs.each do |base_dir|
          if file_path.start_with?(base_dir)
            relative_path = file_path.delete_prefix(base_dir).delete_prefix("/")
            return File.join(compile_classes_dir, relative_path)
          end
        end

        # Fallback: use just the filename
        File.join(compile_classes_dir, File.basename(file_path))
      end

      def content
        content_array = Tailwindcss.resolve_setting(Tailwindcss.config.content)
        content_array.map { |path| absolute_path(path) }
      end
      
      def content_base_dirs
        # Extract base directories from content patterns
        Tailwindcss.resolve_setting(Tailwindcss.config.content).map do |pattern|
          # Remove glob patterns to get base directory
          base = pattern.to_s.gsub(/\*\*\/\*.*$/, '').gsub(/\*.*$/, '')
          absolute_path(base)
        end.uniq
      end

      def absolute_path(path)
        File.expand_path(path)
      end
    end
  end
end
