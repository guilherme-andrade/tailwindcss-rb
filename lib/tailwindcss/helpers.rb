# frozen_string_literal: true

require "tailwindcss/style"
require "tailwindcss/arbitrary_value"

module Tailwindcss
  module Helpers
    module_function

    def tailwind(**style_attributes)
      Style.new(**style_attributes).to_s
    end
    alias_method :tw, :tailwind

    def ab(value)
      ArbitraryValue.new(value)
    end

    # @param token [String] A value your Tailwindcss.theme.color_scheme keys
    # @param weight [Integer] A value between 100 and 900
    def color_scheme_token(token, weight = 500)
      color_token(Tailwindcss.theme.color_scheme[token.to_sym], weight)
    end

    # @param color_token [String] A value your of any of tailwinds color tokens
    # @param weight [Integer] A value between 100 and 900
    def color_token(color_token, weight = 500)
      "#{color_token}-#{weight}"
    end

    # Helper for dark mode variants
    # @param style_attributes [Hash] The styles to apply in dark mode
    # @example
    #   tailwind(bg: :white, **dark(bg: :gray, text: :white))
    #   # => "bg-white dark:bg-gray-500 dark:text-white"
    def dark(**style_attributes)
      {_dark: style_attributes}
    end

    # Helper for responsive variants
    # @param breakpoint [Symbol] The breakpoint (sm, md, lg, xl, 2xl)
    # @param style_attributes [Hash] The styles to apply at this breakpoint
    def at(breakpoint, **style_attributes)
      {"_#{breakpoint}": style_attributes}
    end
  end
end
