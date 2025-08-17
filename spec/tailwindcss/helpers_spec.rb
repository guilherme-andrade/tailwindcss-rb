# frozen_string_literal: true

require "tailwindcss"
require "tailwindcss/helpers"

RSpec.describe Tailwindcss::Helpers do
  include Tailwindcss::Helpers

  before do
    Tailwindcss.init!
  end

  after do
    Tailwindcss.reset_config if Tailwindcss.respond_to?(:reset_config)
  end

  describe "#tailwind" do
    it "generates basic Tailwind classes" do
      expect(tailwind(bg: :red, text: :white)).to eq("bg-red text-white")
    end

    it "handles numeric values" do
      expect(tailwind(p: 4, mt: 2)).to eq("mt-2 p-4")
    end

    it "handles modifiers" do
      result = tailwind(bg: :white, _hover: {bg: :gray})
      expect(result.split(" ")).to match_array(%w[bg-white hover:bg-gray])
    end
  end

  describe "#tw" do
    it "is an alias for tailwind" do
      expect(tw(bg: :red)).to eq(tailwind(bg: :red))
    end
  end

  describe "#dark" do
    it "creates dark mode variants" do
      result = tailwind(bg: :white, **dark(bg: :gray, text: :white))
      expect(result.split(" ")).to match_array(%w[bg-white dark:bg-gray dark:text-white])
    end

    it "can be nested with other modifiers" do
      result = tailwind(**dark(_hover: {bg: :blue}))
      expect(result).to eq("dark:hover:bg-blue")
    end

    it "works with complex styling" do
      result = tailwind(
        bg: :white,
        text: :black,
        **dark(
          bg: :gray,
          text: :white,
          _hover: {bg: :blue}
        )
      )
      expect(result.split(" ")).to match_array(%w[bg-white text-black dark:bg-gray dark:text-white dark:hover:bg-blue])
    end
  end

  describe "#at" do
    it "creates responsive variants" do
      result = tailwind(p: 2, **at(:md, p: 4))
      expect(result.split(" ")).to match_array(%w[p-2 md:p-4])
    end

    it "works with multiple breakpoints" do
      result = tailwind(
        p: 2,
        **at(:sm, p: 3),
        **at(:md, p: 4),
        **at(:lg, p: 6)
      )
      expect(result.split(" ")).to match_array(%w[p-2 sm:p-3 md:p-4 lg:p-6])
    end

    it "combines with dark mode" do
      result = tailwind(**at(:lg, **dark(bg: :black)))
      expect(result).to eq("lg:dark:bg-black")
    end
  end

  describe "#color_scheme_token" do
    before do
      Tailwindcss.reset_config if Tailwindcss.respond_to?(:reset_config)
      Tailwindcss.configure do |config|
        config.theme.color_scheme = {
          primary: :blue,
          secondary: :green,
          danger: :red
        }
      end
      Tailwindcss.init!
    end

    it "returns color scheme token with default weight" do
      expect(color_scheme_token(:primary)).to eq("blue-500")
    end

    it "returns color scheme token with custom weight" do
      expect(color_scheme_token(:danger, 700)).to eq("red-700")
    end

    it "works within tailwind helper" do
      result = tailwind(bg: color_scheme_token(:primary, 100))
      expect(result).to eq("bg-blue-100")
    end
  end

  describe "#color_token" do
    it "returns color token with default weight" do
      expect(color_token(:indigo)).to eq("indigo-500")
    end

    it "returns color token with custom weight" do
      expect(color_token(:purple, 300)).to eq("purple-300")
    end
  end

  describe "#ab" do
    it "creates arbitrary values" do
      expect(ab("[url('/image.png')]")).to be_a(Tailwindcss::ArbitraryValue)
    end
  end
end
