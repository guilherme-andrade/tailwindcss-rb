require "ostruct"
require "tailwindcss/style_attributes_to_list_converter"

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

    private

    def to_string_converter
      @to_string_converter ||= StyleAttributesToListConverter.new
    end
  end
end
