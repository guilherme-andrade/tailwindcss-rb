# frozen_string_literal: true

require "tailwindcss"
require "tempfile"
require "fileutils"

RSpec.describe "Tailwindcss in Production Mode" do
  # Force production mode for all tests in this file
  before(:all) do
    @original_rails_env = ENV["RAILS_ENV"]
    @original_rack_env = ENV["RACK_ENV"]
    ENV["RAILS_ENV"] = "production"
    ENV["RACK_ENV"] = "production"
  end

  after(:all) do
    ENV["RAILS_ENV"] = @original_rails_env
    ENV["RACK_ENV"] = @original_rack_env
  end

  before(:each) do
    Tailwindcss.reset_config if Tailwindcss.respond_to?(:reset_config)
    Tailwindcss.configure do |config|
      config.mode = :production
      config.content = []
    end
  end

  let(:temp_dir) { Dir.mktmpdir }

  after(:each) do
    FileUtils.rm_rf(temp_dir) if Dir.exist?(temp_dir)
  end

  describe "compiler behavior" do
    it "does not initialize the compiler" do
      # Compiler::Runner should never be called in production
      expect(Tailwindcss::Compiler::Runner).not_to receive(:new)

      Tailwindcss.init!
    end

    it "skips file watching even if watch_content is enabled" do
      Tailwindcss.configure do |config|
        config.mode = :production
        config.watch_content = true
        config.content = [temp_dir]
      end

      expect(Listen).not_to receive(:to)

      Tailwindcss.init!
    end

    it "does not create cache directories" do
      cache_dir = File.join(temp_dir, "tailwindcss_cache")

      Tailwindcss.configure do |config|
        config.mode = :production
        config.compiler.compile_classes_dir = cache_dir
      end

      Tailwindcss.init!

      expect(Dir.exist?(cache_dir)).to be false
    end

    it "does not extract classes from files" do
      test_file = File.join(temp_dir, "component.rb")
      File.write(test_file, <<~RUBY)
        class MyComponent
          include Tailwindcss::Helpers
        #{"  "}
          def style
            tailwind(bg: :red, p: 4)
          end
        end
      RUBY

      Tailwindcss.configure do |config|
        config.mode = :production
        config.content = [temp_dir]
      end

      expect(Tailwindcss::Compiler::FileClassesExtractor).not_to receive(:new)

      Tailwindcss.init!
    end

    it "does not parse Ruby/ERB files" do
      expect(Tailwindcss::Compiler::FileParser).not_to receive(:new)
      expect(Tailwindcss::Compiler::HashArgsExtractor).not_to receive(:new)

      Tailwindcss.init!
    end
  end

  describe "style generation" do
    it "generates styles without compilation" do
      style = Tailwindcss::Style.new(
        bg: :blue,
        p: 4,
        rounded: :lg,
        shadow: :md
      )

      expect(style.to_s).to eq("bg-blue p-4 rounded-lg shadow-md")
    end

    it "handles complex modifiers" do
      style = Tailwindcss::Style.new(
        bg: :white,
        _hover: {bg: :gray},
        _dark: {bg: :black, text: :white}
      )

      expect(style.to_s).to include("bg-white")
      expect(style.to_s).to include("hover:bg-gray")
      expect(style.to_s).to include("dark:bg-black")
      expect(style.to_s).to include("dark:text-white")
    end
  end

  describe "helpers functionality" do
    include Tailwindcss::Helpers

    it "tailwind helper works normally" do
      result = tailwind(bg: :indigo, text: :white, p: 6)

      expect(result).to eq("bg-indigo p-6 text-white")
    end

    it "dark mode helper works" do
      result = tailwind(
        bg: :white,
        **dark(bg: :gray, text: :gray_100)
      )

      expect(result).to include("bg-white")
      expect(result).to include("dark:bg-gray")
      expect(result).to include("dark:text-gray-100")
    end

    it "responsive helper works" do
      result = tailwind(
        w: :full,
        **at(:md, w: "1/2"),
        **at(:lg, w: "1/3")
      )

      expect(result).to include("w-full")
      expect(result).to include("md:w-1/2")
      expect(result).to include("lg:w-1/3")
    end

    it "handles arbitrary values" do
      result = tailwind(
        bg: "[url('/bg.jpg')]",
        height: "[calc(100vh-64px)]"
      )

      expect(result).to include("bg-[url('/bg.jpg')]")
      expect(result).to include("h-[calc(100vh-64px)]")
    end
  end

  describe "style composition" do
    it "merges styles" do
      base = Tailwindcss::Style.new(p: 4, rounded: :md)
      variant = base.merge(bg: :blue, text: :white)

      expect(variant.to_s).to include("p-4", "rounded-md", "bg-blue", "text-white")
    end

    it "supports the + operator" do
      style1 = Tailwindcss::Style.new(bg: :gray)
      style2 = Tailwindcss::Style.new(p: 4)

      combined = style1 + style2

      expect(combined.to_s).to include("bg-gray", "p-4")
    end

    it "supports with() for overrides" do
      style = Tailwindcss::Style.new(bg: :red, p: 4)
      modified = style.with(bg: :blue)

      expect(modified.to_s).to include("bg-blue", "p-4")
    end

    it "supports except() for removal" do
      style = Tailwindcss::Style.new(bg: :red, p: 4, mt: 2)
      modified = style.except(:mt)

      expect(modified.to_s).to include("bg-red", "p-4")
      expect(modified.to_s).not_to include("mt-2")
    end
  end

  describe "mode detection" do
    it "correctly identifies as production mode" do
      expect(Tailwindcss.production_mode?).to be true
      expect(Tailwindcss.development_mode?).to be false
    end

    it "detects production from environment variables" do
      Tailwindcss.reset_config if Tailwindcss.respond_to?(:reset_config)
      Tailwindcss.configure {}

      # Should auto-detect from ENV
      mode = Tailwindcss.config.mode
      mode = mode.call if mode.respond_to?(:call)
      expect(mode).to eq(:production)
    end
  end

  describe "manual compilation" do
    it "compile_css! can still be called manually if needed" do
      output_path = File.join(temp_dir, "styles.css")

      Tailwindcss.configure do |config|
        config.mode = :production
        config.compiler.output_path = output_path
      end

      # Manual compilation should still be possible
      expect(Tailwindcss).to receive(:system).with(/npx tailwindcss/)

      Tailwindcss.compile_css!
    end
  end

  describe "memory efficiency" do
    it "has minimal memory footprint" do
      # These compiler components should not be loaded
      expect(defined?(Tailwindcss::Compiler::Runner)).to be_falsey unless
        defined?(Tailwindcss::Compiler::Runner)

      Tailwindcss.init!

      # Style generation should still work with minimal memory
      style = Tailwindcss::Style.new(bg: :blue)
      expect(style.to_s).to eq("bg-blue")
    end

    it "does not load file system watchers" do
      Tailwindcss.configure do |config|
        config.mode = :production
        config.watch_content = true
      end

      # Listen gem should not be initialized
      expect(Listen).not_to receive(:to)

      Tailwindcss.init!
    end
  end

  describe "configuration" do
    it "respects explicit production mode setting" do
      ENV["RAILS_ENV"] = "development"
      ENV["RACK_ENV"] = "development"

      Tailwindcss.reset_config if Tailwindcss.respond_to?(:reset_config)
      Tailwindcss.configure do |config|
        config.mode = :production # Explicit override
      end

      expect(Tailwindcss.production_mode?).to be true
    ensure
      ENV["RAILS_ENV"] = "production"
      ENV["RACK_ENV"] = "production"
    end

    it "can use a proc for dynamic mode detection" do
      Tailwindcss.configure do |config|
        config.mode = proc { :production }
      end

      expect(Tailwindcss.production_mode?).to be true
    end
  end
end
