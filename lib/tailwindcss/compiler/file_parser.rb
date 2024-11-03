module Tailwindcss
  module Compiler
    class FileCompiler
      require "parser/current"
      require "tailwindcss/compiler/hash_args_extractor"

      def call(file_path:)
        file_content = File.read(file_path)
        code = if file_is_ruby?(file_path:)
          extract_ruby_from_rb(file_content:)
        elsif file_is_erb?(file_path:)
          extract_ruby_from_erb(erb: file_content)
        else
          return
        end

        buffer = Parser::Source::Buffer.new(file_path)
        buffer.source = code

        parser = Parser::CurrentRuby.new
        parser.parse(buffer)
      rescue Parser::SyntaxError
        Rails.logger.error("Tailwindcss: Failed to parse #{file_path}. Skipping...")
      end

      private

      def file_is_ruby?(file_path:)
        file_path.end_with?(".rb")
      end

      def file_is_erb?(file_path:)
        file_path.end_with?(".html.erb")
      end

      def erb_template_in_ruby?(file_path:)
        file_is_ruby?(file_path:) && File.read(file_path).match?(/<<(~|-)ERB/)
      end

      def extract_ruby_from_rb(file_content:)
        [file_content, erb_code_from_rb(file_content:)].flatten.compact.join("\n")
      end

      def erb_code_from_rb(file_content:)
        match_erb = file_content.match(/<<[~-]ERB(.*)ERB/m)
        extract_ruby_from_erb(erb: match_erb[1]) if match_erb
      end

      def extract_ruby_from_erb(erb:)
        # Use a regex to extract ruby code from ERB
        erb.scan(/<%=?([\s\S]*?)%>/m).flatten.compact.join("\n")
      end
    end
  end
end
