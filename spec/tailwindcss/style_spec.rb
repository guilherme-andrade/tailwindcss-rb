# frozen_string_literal: true

require "tailwindcss"
require "dry/configurable/test_interface"

Tailwindcss.enable_test_interface

Tailwindcss.init!

RSpec.describe Tailwindcss::Style do
  after do
    Tailwindcss.reset_config
  end

  describe "#to_a" do
    it "returns an array of style attributes" do
      style = Tailwindcss::Style.new(
        bg: :red,
        color: :white,
        _hover: {bg: :blue, _sm: {mt: 10}, _after: {p: 10, _lg: {p: 14}}},
        _before: {content: '[""]'},
        _lg: {mt: 10}
      )
      expect(style.to_a).to match_array(
        %w[bg-red text-white hover:bg-blue hover:sm:mt-10 hover:after:p-10
          hover:after:lg:p-14 before:content-[""] lg:mt-10]
      )
    end

    context "when there is configured prefix" do
      it "returns an array of style attributes with prefix" do
        Tailwindcss.configure do |config|
          config.prefix = "tw"
        end

        style = Tailwindcss::Style.new(
          bg: :red,
          color: :white,
          _hover: {bg: :blue, _sm: {mt: 10}, _after: {p: 10, _lg: {p: 14}}},
          _before: {content: '[""]'},
          _lg: {mt: 10}
        )
        expect(style.to_a).to match_array(
          %w[tw-bg-red tw-text-white tw-hover:bg-blue tw-hover:sm:mt-10 tw-hover:after:p-10
            tw-hover:after:lg:p-14 tw-before:content-[""] tw-lg:mt-10]
        )
      end
    end
  end

  describe "#to_s" do
    it "returns a string of style attributes" do
      style = Tailwindcss::Style.new(
        bg: :red,
        color: :white,
        _hover: {bg: :blue, _sm: {mt: 10}, _after: {p: 10, _lg: {p: 14}}},
        _before: {content: '[""]'},
        _lg: {mt: 10}
      )

      expect(style.to_s.split(" ")).to match_array(
        %w[bg-red text-white hover:bg-blue hover:sm:mt-10 hover:after:p-10
          hover:after:lg:p-14 before:content-[""] lg:mt-10]
      )
    end
  end

  describe "#to_h" do
    it "returns a hash of style attributes" do
      style = Tailwindcss::Style.new(
        bg: :red,
        color: :white,
        _hover: {bg: :blue, _sm: {mt: 10}, _after: {p: 10, _lg: {p: 14}}},
        _before: {content: '[""]'},
        _lg: {mt: 10}
      )

      expect(style.to_h).to eq(
        bg: :red,
        color: :white,
        _hover: {bg: :blue, _sm: {mt: 10}, _after: {p: 10, _lg: {p: 14}}},
        _before: {content: '[""]'},
        _lg: {mt: 10}
      )
    end
  end

  describe "#to_html_attributes" do
    it "returns a hash of style attributes" do
      style = Tailwindcss::Style.new(
        bg: :red,
        color: :white,
        _hover: {bg: :blue, _sm: {mt: 10}, _after: {p: 10, _lg: {p: 14}}},
        _before: {content: '[""]'},
        _lg: {mt: 10}
      )

      expect(style.to_html_attributes).to have_key(:class)
      expect(style.to_html_attributes[:class].split(" ")).to match_array(
        %w[bg-red text-white hover:bg-blue hover:sm:mt-10 hover:after:p-10
          hover:after:lg:p-14 before:content-[""] lg:mt-10]
      )
    end
  end

  describe "#merge" do
    it "merges two Style objects" do
      base_style = Tailwindcss::Style.new(bg: :red, p: 4)
      additional_style = Tailwindcss::Style.new(mt: 2, bg: :blue)

      merged = base_style.merge(additional_style)

      expect(merged.to_s.split(" ")).to match_array(%w[bg-blue mt-2 p-4])
    end

    it "merges a hash into a Style object" do
      base_style = Tailwindcss::Style.new(bg: :red, p: 4)

      merged = base_style.merge(mt: 2, bg: :blue)

      expect(merged.to_s.split(" ")).to match_array(%w[bg-blue mt-2 p-4])
    end

    it "deep merges modifiers" do
      base_style = Tailwindcss::Style.new(bg: :red, _hover: {bg: :blue})

      merged = base_style.merge(_hover: {text: :white})

      expect(merged.to_s.split(" ")).to match_array(%w[bg-red hover:bg-blue hover:text-white])
    end
  end

  describe "#+" do
    it "works as an alias for merge" do
      style1 = Tailwindcss::Style.new(bg: :red)
      style2 = Tailwindcss::Style.new(text: :white)

      combined = style1 + style2

      expect(combined.to_s.split(" ")).to match_array(%w[bg-red text-white])
    end
  end

  describe "#with" do
    it "overrides specific attributes" do
      style = Tailwindcss::Style.new(bg: :red, p: 4, mt: 2)

      modified = style.with(bg: :blue, mb: 3)

      expect(modified.to_s.split(" ")).to match_array(%w[bg-blue mb-3 mt-2 p-4])
    end
  end

  describe "#except" do
    it "removes specific attributes" do
      style = Tailwindcss::Style.new(bg: :red, p: 4, mt: 2)

      modified = style.except(:p, :mt)

      expect(modified.to_s.split(" ")).to match_array(%w[bg-red])
    end
  end

  describe "#empty?" do
    it "returns true for empty styles" do
      style = Tailwindcss::Style.new
      expect(style.empty?).to be true
    end

    it "returns false for styles with attributes" do
      style = Tailwindcss::Style.new(bg: :red)
      expect(style.empty?).to be false
    end
  end
end
