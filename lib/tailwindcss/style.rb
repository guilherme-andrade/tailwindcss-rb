# frozen_string_literal: true

require "ostruct"
require "tailwindcss/style_attributes_to_list_converter"
require "active_support/core_ext/hash/deep_merge"
require "active_support/core_ext/hash/except"

module Tailwindcss
  class Style < ::OpenStruct
    def initialize(attributes = {})
      super
      @attributes = attributes
    end

    def to_a
      to_string_converter.call(**@attributes)
    end

    def to_s
      to_a.join(" ")
    end

    def to_html_attributes
      {class: to_s}
    end

    # Merge another Style object or hash into this one
    # @param other [Style, Hash] The styles to merge
    # @return [Style] A new Style object with merged attributes
    def merge(other)
      other_attrs = other.is_a?(Style) ? other.to_h : other
      Style.new(@attributes.deep_merge(other_attrs))
    end
    alias_method :+, :merge

    # Override specific attributes
    # @param attributes [Hash] The attributes to override
    # @return [Style] A new Style object with overridden attributes
    def with(**attributes)
      Style.new(@attributes.merge(attributes))
    end

    # Remove specific attributes
    # @param keys [Array<Symbol>] The attribute keys to remove
    # @return [Style] A new Style object without the specified attributes
    def except(*keys)
      Style.new(@attributes.except(*keys))
    end

    # Check if the style has any attributes
    # @return [Boolean]
    def empty?
      @attributes.empty?
    end

    private

    def to_string_converter
      @to_string_converter ||= StyleAttributesToListConverter.new
    end
  end
end
