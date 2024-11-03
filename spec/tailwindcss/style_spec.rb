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

      expect(style.to_s.split(' ')).to match_array(
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
      expect(style.to_html_attributes[:class].split(' ')).to match_array(
        %w[bg-red text-white hover:bg-blue hover:sm:mt-10 hover:after:p-10
          hover:after:lg:p-14 before:content-[""] lg:mt-10]
      )
    end
  end
end
