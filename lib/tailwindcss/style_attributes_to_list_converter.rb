# frozen_string_literal: true

require "dry/initializer"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/string/inflections"
require "active_support/core_ext/enumerable"

module Tailwindcss
  class StyleAttributesToListConverter
    extend Dry::Initializer

    def call(**style)
      # Don't add prefix here - let Tailwind handle it
      build_style_prop_classes(style.to_h)
    end

    private

    def build_style_prop_classes(style)
      style.flat_map { |(style_prop, value)| classes_for_style_prop(style_prop, value) }
        .compact_blank
        .sort
    end

    def classes_for_style_prop(style_prop, value)
      token = get_token(style_prop)
      return build_style_prop_classes(value).map { "#{token}:#{_1}" } if style_prop.start_with?("_")
      return token if value.to_s == "true"
      return nil if value.to_s == "false"

      # Handle arbitrary values wrapped in brackets
      value_str = value.to_s
      return "#{token}-#{value_str}" if value_str.start_with?("[") && value_str.end_with?("]")

      [token, value_str.dasherize].compact_blank.join("-")
    end

    def get_token(name_or_alias)
      return name_or_alias[1..] if name_or_alias.start_with?("_")

      result = Tailwindcss.theme.to_h.find { _1 == name_or_alias || _2[:alias] == name_or_alias }
      result ? result.last[:token] : name_or_alias.to_s.dasherize
    end
  end
end
