# frozen_string_literal: true

require "tailwindcss"
require "tempfile"
require "fileutils"

RSpec.describe "Tailwindcss in Development Mode" do
  # Force development mode for all tests in this file
  before(:all) do
    @original_rails_env = ENV["RAILS_ENV"]
    @original_rack_env = ENV["RACK_ENV"]
    ENV["RAILS_ENV"] = "development"
    ENV["RACK_ENV"] = "development"
  end

  after(:all) do
    ENV["RAILS_ENV"] = @original_rails_env
    ENV["RACK_ENV"] = @original_rack_env
  end

  before(:each) do
    Tailwindcss.reset_config if Tailwindcss.respond_to?(:reset_config)
    Tailwindcss.configure do |config|
      config.mode = :development
      config.content = []
      config.watch_content = false # Disable by default for tests
    end
  end

  let(:temp_dir) { Dir.mktmpdir }

  after(:each) do
    FileUtils.rm_rf(temp_dir) if Dir.exist?(temp_dir)
  end

  describe "compiler behavior" do
    it "initializes the compiler in development mode" do
      runner_double = double("Runner", call: nil)
      expect(Tailwindcss::Compiler::Runner).to receive(:new).and_return(runner_double)

      Tailwindcss.init!
    end

    it "watches files when watch_content is enabled" do
      test_file = File.join(temp_dir, "test.rb")
      File.write(test_file, "tailwind(bg: :red)")

      Tailwindcss.configure do |config|
        config.mode = :development
        config.watch_content = true
        config.content = [temp_dir]
      end

      listener_double = double("Listener", start: nil)
      expect(Listen).to receive(:to).at_least(:once).and_return(listener_double)

      Tailwindcss.init!
    end

    it "creates cache directories" do
      cache_dir = File.join(temp_dir, "tailwindcss_cache")
      test_file = File.join(temp_dir, "test.rb")
      File.write(test_file, "tailwind(bg: :red)")

      Tailwindcss.configure do |config|
        config.mode = :development
        config.compiler.compile_classes_dir = cache_dir
        config.content = [temp_dir]
      end

      Tailwindcss.init!

      expect(Dir.exist?(cache_dir)).to be true
    end

    it "extracts classes from Ruby files" do
      test_file = File.join(temp_dir, "component.rb")
      File.write(test_file, <<~RUBY)
        class MyComponent
          include Tailwindcss::Helpers
        #{"  "}
          def style
            tailwind(bg: :red, p: 4, rounded: :lg)
          end
        end
      RUBY

      Tailwindcss.configure do |config|
        config.mode = :development
        config.content = [temp_dir]
      end

      # Should extract classes
      extractor = Tailwindcss::Compiler::FileClassesExtractor.new
      classes = extractor.call(file_path: test_file)

      expect(classes).to include("bg-red", "p-4", "rounded-lg")
    end

    it "extracts classes from ERB files" do
      test_file = File.join(temp_dir, "template.html.erb")
      File.write(test_file, <<~ERB)
        <div class="<%= tailwind(container: true, mx: :auto) %>">
          <h1 class="<%= tw(text: :xl, font: :bold) %>">Title</h1>
        </div>
      ERB

      Tailwindcss.configure do |config|
        config.mode = :development
        config.content = [temp_dir]
      end

      extractor = Tailwindcss::Compiler::FileClassesExtractor.new
      classes = extractor.call(file_path: test_file)

      expect(classes).to include("container", "mx-auto", "text-xl", "font-bold")
    end
  end

  describe "compilation process" do
    it "calls npx tailwindcss to compile CSS" do
      output_path = File.join(temp_dir, "styles.css")

      Tailwindcss.configure do |config|
        config.mode = :development
        config.compiler.assets_path = temp_dir
        config.compiler.output_file_name = "styles"
      end

      expect(Tailwindcss).to receive(:system).with(/npx tailwindcss.*-o.*#{output_path}/)

      Tailwindcss.compile_css!
    end

    it "processes all files in content paths" do
      file1 = File.join(temp_dir, "file1.rb")
      file2 = File.join(temp_dir, "file2.rb")

      File.write(file1, "tailwind(bg: :blue)")
      File.write(file2, "tailwind(text: :white)")

      Tailwindcss.configure do |config|
        config.mode = :development
        config.content = [temp_dir]
      end

      Tailwindcss::Compiler::Output.new
      extractor = Tailwindcss::Compiler::FileClassesExtractor.new

      classes1 = extractor.call(file_path: file1)
      classes2 = extractor.call(file_path: file2)

      expect(classes1).to include("bg-blue")
      expect(classes2).to include("text-white")
    end
  end

  describe "caching behavior" do
    it "caches parsed ASTs" do
      test_file = File.join(temp_dir, "cached.rb")
      File.write(test_file, "tailwind(bg: :green, p: 4)")

      cache_dir = File.join(temp_dir, "cache")

      Tailwindcss.configure do |config|
        config.mode = :development
        config.compiler.compile_classes_dir = cache_dir
      end

      extractor = Tailwindcss::Compiler::FileClassesExtractor.new

      # First call should parse
      classes1 = extractor.call(file_path: test_file)

      # Second call should use cache
      classes2 = extractor.call(file_path: test_file)

      expect(classes1).to eq(classes2)
      expect(File.exist?(File.join(cache_dir, "ast_cache.json"))).to be true
    end

    it "invalidates cache when file changes" do
      test_file = File.join(temp_dir, "changing.rb")
      File.write(test_file, "tailwind(bg: :red)")

      extractor = Tailwindcss::Compiler::FileClassesExtractor.new

      classes1 = extractor.call(file_path: test_file)
      expect(classes1).to include("bg-red")

      # Modify file
      sleep(0.01) # Ensure mtime changes
      File.write(test_file, "tailwind(bg: :blue)")

      classes2 = extractor.call(file_path: test_file)
      expect(classes2).to include("bg-blue")
      expect(classes2).not_to include("bg-red")
    end
  end

  describe "file watching" do
    it "recompiles when files change" do
      test_file = File.join(temp_dir, "watched.rb")
      File.write(test_file, "tailwind(bg: :red)")

      Tailwindcss.configure do |config|
        config.mode = :development
        config.watch_content = true
        config.content = [temp_dir]
      end

      modified_callback = nil
      listener_double = double("Listener")

      expect(Listen).to receive(:to) do |_path, _options, &block|
        modified_callback = block
        listener_double
      end
      expect(listener_double).to receive(:start)

      Tailwindcss.init!

      # Simulate file modification
      if modified_callback
        expect(Tailwindcss).to receive(:compile_css!)
        modified_callback.call([test_file], [], [])
      end
    end

    it "handles file additions" do
      Tailwindcss.configure do |config|
        config.mode = :development
        config.watch_content = true
        config.content = [temp_dir]
      end

      added_callback = nil
      listener_double = double("Listener")

      expect(Listen).to receive(:to) do |_path, _options, &block|
        added_callback = block
        listener_double
      end
      expect(listener_double).to receive(:start)

      Tailwindcss.init!

      # Simulate file addition
      new_file = File.join(temp_dir, "new.rb")
      File.write(new_file, "tailwind(mt: 4)")

      if added_callback
        expect(Tailwindcss).to receive(:compile_css!)
        added_callback.call([], [new_file], [])
      end
    end

    it "handles file deletions" do
      deleted_file = File.join(temp_dir, "deleted.rb")
      File.write(deleted_file, "tailwind(mb: 4)")

      Tailwindcss.configure do |config|
        config.mode = :development
        config.watch_content = true
        config.content = [temp_dir]
      end

      removed_callback = nil
      listener_double = double("Listener")

      expect(Listen).to receive(:to) do |_path, _options, &block|
        removed_callback = block
        listener_double
      end
      expect(listener_double).to receive(:start)

      Tailwindcss.init!

      # Simulate file deletion
      FileUtils.rm(deleted_file)

      if removed_callback
        expect(Tailwindcss).to receive(:compile_css!)
        removed_callback.call([], [], [deleted_file])
      end
    end
  end

  describe "mode detection" do
    it "correctly identifies as development mode" do
      expect(Tailwindcss.development_mode?).to be true
      expect(Tailwindcss.production_mode?).to be false
    end

    it "defaults to development when environment is not production" do
      ENV["RAILS_ENV"] = "test"
      ENV["RACK_ENV"] = "test"

      Tailwindcss.reset_config if Tailwindcss.respond_to?(:reset_config)
      Tailwindcss.configure {}

      mode = Tailwindcss.config.mode
      mode = mode.call if mode.respond_to?(:call)
      expect(mode).to eq(:development)
    ensure
      ENV["RAILS_ENV"] = "development"
      ENV["RACK_ENV"] = "development"
    end

    it "defaults to development when no environment is set" do
      ENV["RAILS_ENV"] = nil
      ENV["RACK_ENV"] = nil

      Tailwindcss.reset_config if Tailwindcss.respond_to?(:reset_config)
      Tailwindcss.configure {}

      mode = Tailwindcss.config.mode
      mode = mode.call if mode.respond_to?(:call)
      expect(mode).to eq(:development)
    ensure
      ENV["RAILS_ENV"] = "development"
      ENV["RACK_ENV"] = "development"
    end
  end

  describe "configuration" do
    it "respects explicit development mode setting" do
      ENV["RAILS_ENV"] = "production"
      ENV["RACK_ENV"] = "production"

      Tailwindcss.reset_config if Tailwindcss.respond_to?(:reset_config)
      Tailwindcss.configure do |config|
        config.mode = :development # Explicit override
      end

      expect(Tailwindcss.development_mode?).to be true
    ensure
      ENV["RAILS_ENV"] = "development"
      ENV["RACK_ENV"] = "development"
    end

    it "can use a proc for dynamic mode detection" do
      some_condition = false

      Tailwindcss.configure do |config|
        config.mode = proc { some_condition ? :production : :development }
      end

      expect(Tailwindcss.development_mode?).to be true

      some_condition = true
      expect(Tailwindcss.production_mode?).to be true
    end
  end

  describe "error handling" do
    it "handles missing files gracefully" do
      non_existent = File.join(temp_dir, "missing.rb")

      extractor = Tailwindcss::Compiler::FileClassesExtractor.new

      expect { extractor.call(file_path: non_existent) }.not_to raise_error
    end

    it "handles syntax errors in Ruby files" do
      bad_file = File.join(temp_dir, "syntax_error.rb")
      File.write(bad_file, "def broken\n  tailwind(bg: :red") # Missing closing paren

      extractor = Tailwindcss::Compiler::FileClassesExtractor.new

      expect { extractor.call(file_path: bad_file) }.not_to raise_error
    end

    it "handles malformed ERB files" do
      bad_erb = File.join(temp_dir, "bad.html.erb")
      File.write(bad_erb, "<%= tailwind(bg: :red %>") # Missing closing paren

      extractor = Tailwindcss::Compiler::FileClassesExtractor.new

      expect { extractor.call(file_path: bad_erb) }.not_to raise_error
    end
  end
end
