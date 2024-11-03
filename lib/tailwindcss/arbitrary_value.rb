module Tailwindcss
  class ArbitraryValue
    def initialize(value)
      @value = value
    end

    def to_s
      "[#{@value}]"
    end

    def inspect
      to_s
    end
  end
end
