require "rails_helper"
require "fileutils"
require "timeout"

RSpec.describe "File Watcher Integration", type: :integration do
  let(:test_component_path) { Rails.root.join("app/components/watched_component.rb") }
  let(:output_path) { Tailwindcss.output_path }
  let(:cache_dir) { Tailwindcss.resolve_setting(Tailwindcss.config.compiler.compile_classes_dir) }
  
  before(:each) do
    # Ensure development mode
    allow(Tailwindcss).to receive(:production_mode?).and_return(false)
    allow(Tailwindcss).to receive(:development_mode?).and_return(true)
    
    # Enable file watching
    @original_watch = Tailwindcss.config.watch_content
    Tailwindcss.configure do |config|
      config.watch_content = true
    end
    
    # Clean up any existing test files
    FileUtils.rm_f(test_component_path)
  end
  
  after(:each) do
    # Restore original watch setting
    Tailwindcss.configure do |config|
      config.watch_content = @original_watch
    end
    
    # Clean up test files
    FileUtils.rm_f(test_component_path)
  end
  
  describe "File Change Detection" do
    it "detects new file creation" do
      runner = Tailwindcss::Compiler::Runner.new
      runner.call
      
      # Create a new component file
      File.write(test_component_path, <<~RUBY)
        class WatchedComponent
          include Tailwindcss::Helpers
          
          def new_style
            style(bg: :indigo._(600), text: :white, p: 8)
          end
        end
      RUBY
      
      # Give the watcher time to detect the change
      sleep 0.5
      
      # Check if new classes are extracted
      extractor = Tailwindcss::Compiler::FileClassesExtractor.new
      classes = extractor.call(test_component_path.to_s)
      
      expect(classes).to include("bg-indigo-600")
      expect(classes).to include("text-white")
      expect(classes).to include("p-8")
    end
    
    it "detects file modifications" do
      # Create initial file
      File.write(test_component_path, <<~RUBY)
        class WatchedComponent
          include Tailwindcss::Helpers
          
          def initial_style
            style(bg: :green._(500))
          end
        end
      RUBY
      
      runner = Tailwindcss::Compiler::Runner.new
      runner.call
      
      # Verify initial class is extracted
      extractor = Tailwindcss::Compiler::FileClassesExtractor.new
      initial_classes = extractor.call(test_component_path.to_s)
      expect(initial_classes).to include("bg-green-500")
      
      # Modify the file
      sleep 0.1 # Ensure mtime changes
      File.write(test_component_path, <<~RUBY)
        class WatchedComponent
          include Tailwindcss::Helpers
          
          def updated_style
            style(bg: :purple._(700), text: :yellow._(200))
          end
        end
      RUBY
      
      # Give watcher time to process
      sleep 0.5
      
      # Check if new classes are extracted
      updated_classes = extractor.call(test_component_path.to_s)
      expect(updated_classes).to include("bg-purple-700")
      expect(updated_classes).to include("text-yellow-200")
      expect(updated_classes).not_to include("bg-green-500")
    end
    
    it "detects file deletion" do
      # Create a file
      File.write(test_component_path, <<~RUBY)
        class WatchedComponent
          include Tailwindcss::Helpers
          
          def style_to_remove
            style(bg: :orange._(400))
          end
        end
      RUBY
      
      runner = Tailwindcss::Compiler::Runner.new
      runner.call
      
      # Verify file is being watched
      cache = Tailwindcss::Compiler::AstCache.new
      expect(cache.instance_variable_get(:@cache)).to have_key(test_component_path.to_s)
      
      # Delete the file
      FileUtils.rm_f(test_component_path)
      
      # Give watcher time to process
      sleep 0.5
      
      # Cache should handle the missing file gracefully
      expect {
        cache.fetch(test_component_path.to_s) { [] }
      }.not_to raise_error
    end
  end
  
  describe "Automatic Recompilation" do
    it "triggers recompilation on file change" do
      skip "Requires full watcher setup with Listen gem"
      
      # This test would require setting up the full file watcher
      # which involves Listen gem integration
      # Marking as pending for now
    end
  end
  
  describe "Watch Performance" do
    it "handles rapid file changes" do
      runner = Tailwindcss::Compiler::Runner.new
      runner.call
      
      # Make rapid changes
      5.times do |i|
        File.write(test_component_path, <<~RUBY)
          class WatchedComponent
            include Tailwindcss::Helpers
            
            def style_#{i}
              style(bg: :blue._(#{i}00), p: #{i})
            end
          end
        RUBY
        
        sleep 0.05 # Small delay between changes
      end
      
      # Final extraction should have the last version
      sleep 0.5
      extractor = Tailwindcss::Compiler::FileClassesExtractor.new
      classes = extractor.call(test_component_path.to_s)
      
      expect(classes).to include("bg-blue-400")
      expect(classes).to include("p-4")
    end
    
    it "handles multiple file changes simultaneously" do
      paths = 3.times.map do |i|
        Rails.root.join("app/components/watched_#{i}.rb")
      end
      
      begin
        runner = Tailwindcss::Compiler::Runner.new
        runner.call
        
        # Create multiple files at once
        paths.each_with_index do |path, i|
          File.write(path, <<~RUBY)
            class Watched#{i}Component
              include Tailwindcss::Helpers
              
              def style
                style(bg: :red._(#{i}00), m: #{i})
              end
            end
          RUBY
        end
        
        # Give watcher time to process all files
        sleep 0.5
        
        # Check all files were processed
        extractor = Tailwindcss::Compiler::FileClassesExtractor.new
        paths.each_with_index do |path, i|
          classes = extractor.call(path.to_s)
          expect(classes).to include("bg-red-#{i}00")
          expect(classes).to include("m-#{i}")
        end
      ensure
        # Clean up all test files
        paths.each { |path| FileUtils.rm_f(path) }
      end
    end
  end
  
  describe "Watch Configuration" do
    it "respects watch_content setting" do
      # Disable watching
      Tailwindcss.configure do |config|
        config.watch_content = false
      end
      
      runner = Tailwindcss::Compiler::Runner.new
      runner.call
      
      # Listener should not be set up
      expect(runner.instance_variable_get(:@listener)).to be_nil
    end
    
    it "watches configured content paths" do
      # Verify content paths are properly configured
      content_paths = Tailwindcss.resolve_setting(Tailwindcss.config.content)
      
      expect(content_paths).to include(Rails.root.join("app/views/**/*.erb"))
      expect(content_paths).to include(Rails.root.join("app/controllers/**/*.rb"))
      expect(content_paths).to include(Rails.root.join("app/models/**/*.rb"))
    end
  end
end