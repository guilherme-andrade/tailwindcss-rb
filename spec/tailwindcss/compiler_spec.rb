# frozen_string_literal: true

require "tailwindcss"
require "dry/configurable/test_interface"

Tailwindcss.enable_test_interface

RSpec.describe Tailwindcss::Compiler::Runner, :aggregate_failures do
  let(:runner) { described_class.new }

  let(:css_content) do
    File.read("./spec/tmp/tailwindcss/styles.css")
  end

  let(:classes_content) do
    File.read("./spec/tmp/tailwindcss/test.rb.classes")
  end

  before :all do
    Tailwindcss.configure do |config|
      config.content = proc { ["./spec/test/dummy_project"] }
      config.compiler.assets_path = proc { "./spec/tmp/tailwindcss" }
      config.compiler.output_file_name = proc { "styles" }
      config.compiler.compile_classes_dir = proc { "./spec/tmp/tailwindcss" }
      config.theme.color_scheme = {
        primary: :red,
        secondary: :blue
      }
    end
  end

  before do
    FileUtils.rm_rf("./spec/tmp")
  end

  describe "#call" do
    it "compiles classes" do
      runner.call
      expect(File.exist?("./spec/tmp/tailwindcss/test.rb.classes")).to be_truthy
      expect(classes_content.split(/\s/)).to match_array(%w[bg-red text-red-100 border-blue-500 hover:bg-blue
        hover:sm:mt-10 hover:after:p-10 flex decoration-red-500
        hover:after:lg:p-14 before:content-[""] lg:mt-10])
    end

    context "when the file changes and watch_content is enabled" do
      it "recompiles classes", aggregate_failures: false do
        Tailwindcss.configure do |config|
          config.watch_content = true
        end

        expect(Listen).to receive(:to).and_call_original

        runner.call
      end
    end
  end
end
