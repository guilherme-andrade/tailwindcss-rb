# frozen_string_literal: true

module Tailwindcss
  module Compiler
    class MagicCommentExtractor
      # Pattern to match @tw-whitelist directives in comments
      # Matches: # @tw-whitelist class1 class2 class3
      WHITELIST_PATTERN = /^\s*#\s*@tw-whitelist\s+(.+)$/
      
      def call(file_content)
        classes = []
        
        # Extract from each line that matches the pattern
        file_content.each_line do |line|
          if match = line.match(WHITELIST_PATTERN)
            # Extract the classes part and split by whitespace
            class_list = match[1].strip
            classes.concat(class_list.split(/\s+/))
          end
        end
        
        classes.uniq
      end
      
      # Extract from ERB files (handles both Ruby comments and ERB comments)
      def extract_from_erb(erb_content)
        classes = []
        
        # Extract from Ruby code blocks in ERB (including comments within)
        erb_content.scan(/<%[=\-]?(.*?)%>/m) do |match|
          erb_block_content = match[0]
          # Look for @tw-whitelist in the ERB block
          erb_block_content.scan(/#\s*@tw-whitelist\s+(.+)$/) do |whitelist_match|
            classes.concat(whitelist_match[0].strip.split(/\s+/))
          end
        end
        
        # Also extract from HTML comments that might contain directives
        # <!-- @tw-whitelist class1 class2 -->
        erb_content.scan(/<!--\s*@tw-whitelist\s+(.+?)\s*-->/m) do |match|
          classes.concat(match[0].split(/\s+/))
        end
        
        classes.uniq
      end
    end
  end
end