# frozen_string_literal: true

require "active_support/core_ext/object/blank"
require "tailwindcss/helpers"

module Tailwindcss
  module Compiler
    class HashArgsExtractor
      def call(ast:)
        extract_hash_arguments_from_ast_nodes(ast)
      end

      private

      def extract_hash_arguments_from_ast_nodes(node)
        hash_args = []
        return unless node.is_a?(Parser::AST::Node)

        hash_args += extract_hashes(node).flatten(10) if node.type == :send

        node.children.each do |child|
          next unless child.is_a?(Parser::AST::Node)

          hash_args += extract_hash_arguments_from_ast_nodes(child)
        end

        hash_args.flatten.compact
      end

      def extract_hashes(node)
        scan_for_hash_children(node).each_with_object([]) { |hash_node, acc| extract_value(hash_node, acc) }.compact
      end

      def scan_for_hash_children(node)
        node.children[2..].select { |child| child.type == :hash }
      end

      def extract_value(node, acc)
        node.children.select { |n| n.type == :pair }.each do |key_value_node|
          key_node = key_value_node.children.first
          value_node = key_value_node.children.last
          value = pair_node_value(key_node, value_node)

          acc << value if value.present?
        end
      end

      def pair_node_value(key_node, value_node)
        key = source_code(key_node)
        case value_node.type
        when :hash
          hashes = []
          extract_value(value_node, hashes)
          hashes.flatten.map { |h| {key.to_sym => h} }
        when :int, :str, :sym, :float
          {key.to_sym => node_text(value_node)}
        when :true # standard:disable Lint/BooleanSymbol
          {key.to_sym => true}
        when :false # standard:disable Lint/BooleanSymbol
          {key.to_sym => false}
        else
          extract_color_scheme_calls(key_node, value_node)
        end
      end

      def extract_color_scheme_calls(key_node, value_node)
        value = source_code(value_node)
        return unless value.include?("color_scheme_token") || value.include?("color_token")

        weight_node = value_node.children[3]
        weight = weight_node ? safe_eval(source_code(weight_node), 500) : 500

        if value.include?("color_scheme_token")
          color_scheme_token = safe_eval(source_code(value_node.children[2]), nil)
          return unless color_scheme_token

          color = Tailwindcss::Helpers.color_scheme_token(color_scheme_token, weight)
        elsif value.include?("color_token")
          color_token = safe_eval(source_code(value_node.children[2]), nil)
          return unless color_token

          color = Tailwindcss::Helpers.color_token(color_token, weight)
        end

        {source_code(key_node).to_sym => color}
      rescue => e
        Tailwindcss.logger.debug "Failed to extract color scheme call: #{e.message}"
        nil
      end

      def safe_eval(code, default)
        # Only allow simple literals and symbols for safety
        return default unless code.match?(/\A[:'"a-zA-Z0-9_]+\z/)

        eval(code) # standard:disable Security/Eval
      rescue
        default
      end

      def node_text(node)
        text = source_code(node)
        # Remove leading colon for symbols
        text = text[1..] if text.start_with?(":")
        # Remove quotes for strings but preserve content
        if (text.start_with?('"') && text.end_with?('"')) || (text.start_with?("'") && text.end_with?("'"))
          text = text[1..-2]
        end
        text
      end

      def source_code(node)
        node.location.expression.source
      end
    end
  end
end
