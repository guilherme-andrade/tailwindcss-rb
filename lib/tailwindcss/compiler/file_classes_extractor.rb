module Tailwindcss
  module Compiler
    class FileClassesExtractor
      require "tailwindcss/compiler/output"
      require "tailwindcss/compiler/file_parser"
      require "tailwindcss/compiler/ast_cache"

      def initialize
        @cache = AstCache.new
        @file_parser = FileParser.new
        @hash_args_extractor = HashArgsExtractor.new
        @class_list_builder = StyleAttributesToListConverter.new
      end

      def call(file_path:)
        @cache.fetch(file_path) do
          ast = @file_parser.call(file_path:)
          next unless ast

          hash_args = @hash_args_extractor.call(ast:)
          hash_args.map { @class_list_builder.call(**_1) }.flatten.compact
        end
      end

      def clear_cache
        @cache.clear
      end
    end
  end
end
