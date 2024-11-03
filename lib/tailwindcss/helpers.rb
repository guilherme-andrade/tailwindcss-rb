module Tailwindcss
  module Helpers
    extend self

    def tailwind(**style_attributes)
      Style.new(**style_attributes).to_s
    end
    alias tw tailwind

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
  end
end
