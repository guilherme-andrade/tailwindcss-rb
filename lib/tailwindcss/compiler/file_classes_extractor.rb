module Tailwindcss
  module Compiler
    class FileClassesExtractor
      require "tailwindcss/compiler/output"
      require "tailwindcss/compiler/file_parser"

      def call(file_path:)
        ast = file_parser.call(file_path:)
        return unless ast

        hash_args = hash_args_extractor.call(ast:)
        hash_args.map { class_list_builder.call(**_1) }.flatten.compact
      end

      private

      def hash_args_extractor = HashArgsExtractor.new

      def file_parser = FileCompiler.new

      def class_list_builder = StyleAttributesToListConverter.new
    end
  end
end
