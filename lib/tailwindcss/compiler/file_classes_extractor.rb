module Tailwindcss
  module Compiler
    class FileClassesExtractor
      require "tailwindcss/compiler/output"
      require "tailwindcss/compiler/file_parser"
      require "tailwindcss/compiler/ast_cache"
      require "tailwindcss/compiler/magic_comment_extractor"

      def initialize
        @cache = AstCache.new
        @file_parser = FileParser.new
        @hash_args_extractor = HashArgsExtractor.new
        @class_list_builder = StyleAttributesToListConverter.new
        @magic_comment_extractor = MagicCommentExtractor.new
      end

      def call(file_path:)
        @cache.fetch(file_path) do
          # Extract classes from AST
          ast = @file_parser.call(file_path:)
          ast_classes = if ast
            hash_args = @hash_args_extractor.call(ast:)
            hash_args.map { @class_list_builder.call(**_1) }.flatten.compact
          else
            []
          end
          
          # Extract classes from magic comments
          magic_classes = extract_magic_comment_classes(file_path)
          
          # Combine both sources
          (ast_classes + magic_classes).uniq
        end
      end
      
      private
      
      def extract_magic_comment_classes(file_path)
        return [] unless File.exist?(file_path)
        
        file_content = File.read(file_path)
        
        if file_path.end_with?('.erb', '.html.erb')
          @magic_comment_extractor.extract_from_erb(file_content)
        else
          @magic_comment_extractor.call(file_content)
        end
      rescue => e
        Tailwindcss.log_warn "Failed to extract magic comments from #{file_path}: #{e.message}"
        []
      end

      def clear_cache
        @cache.clear
      end
    end
  end
end
