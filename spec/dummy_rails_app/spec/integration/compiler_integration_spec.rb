require "rails_helper"
require "fileutils"

RSpec.describe "Compiler Integration", type: :integration do
  let(:output_path) { Tailwindcss.output_path }
  let(:cache_dir) { Tailwindcss.resolve_setting(Tailwindcss.config.compiler.compile_classes_dir) }
  let(:test_file_path) { Rails.root.join("app/components/test_component.rb") }
  
  before(:each) do
    # Clear cache before each test
    FileUtils.rm_rf(cache_dir) if Dir.exist?(cache_dir)
    FileUtils.rm_f(output_path) if File.exist?(output_path)
    
    # Ensure we're in development mode for most tests
    allow(Tailwindcss).to receive(:production_mode?).and_return(false)
    allow(Tailwindcss).to receive(:development_mode?).and_return(true)
  end
  
  after(:each) do
    # Clean up test files
    FileUtils.rm_f(test_file_path) if File.exist?(test_file_path)
  end
  
  describe "Class Extraction" do
    it "extracts classes from Ruby component files" do
      runner = Tailwindcss::Compiler::Runner.new
      
      # Get classes from our button component
      extractor = Tailwindcss::Compiler::FileClassesExtractor.new
      classes = extractor.call(Rails.root.join("app/components/button_component.rb").to_s)
      
      expect(classes).to include("px-4")
      expect(classes).to include("py-2")
      expect(classes).to include("rounded-lg")
      expect(classes).to include("font-medium")
      expect(classes).to include("bg-blue-500")
      expect(classes).to include("text-white")
      expect(classes).to include("hover:bg-blue-600")
    end
    
    it "extracts classes from ERB templates" do
      extractor = Tailwindcss::Compiler::FileClassesExtractor.new
      classes = extractor.call(Rails.root.join("app/views/components/_button.html.erb").to_s)
      
      expect(classes).to include("disabled:opacity-50")
      expect(classes).to include("disabled:cursor-not-allowed")
      expect(classes).to include("inline-flex")
      expect(classes).to include("items-center")
      expect(classes).to include("gap-2")
      expect(classes).to include("w-4")
      expect(classes).to include("h-4")
    end
    
    it "extracts dark mode classes" do
      extractor = Tailwindcss::Compiler::FileClassesExtractor.new
      classes = extractor.call(Rails.root.join("app/components/card_component.rb").to_s)
      
      expect(classes).to include("dark:bg-gray-800")
      expect(classes).to include("dark:border-gray-700")
      expect(classes).to include("dark:text-white")
    end
    
    it "extracts responsive classes" do
      extractor = Tailwindcss::Compiler::FileClassesExtractor.new
      classes = extractor.call(Rails.root.join("app/components/card_component.rb").to_s)
      
      expect(classes).to include("sm:p-4")
      expect(classes).to include("md:p-6")
      expect(classes).to include("lg:p-8")
    end
    
    it "handles color weight notation" do
      extractor = Tailwindcss::Compiler::FileClassesExtractor.new
      classes = extractor.call(Rails.root.join("app/components/button_component.rb").to_s)
      
      expect(classes).to include("bg-blue-500")
      expect(classes).to include("hover:bg-blue-600")
      expect(classes).to include("bg-gray-200")
      expect(classes).to include("text-gray-800")
    end
  end
  
  describe "Compilation Process" do
    it "compiles CSS with extracted classes" do
      runner = Tailwindcss::Compiler::Runner.new
      runner.call
      
      expect(File.exist?(output_path)).to be true
      
      css_content = File.read(output_path)
      expect(css_content).to include(".px-4")
      expect(css_content).to include(".bg-blue-500")
      expect(css_content).to include(".rounded-lg")
    end
    
    it "creates output directory if it doesn't exist" do
      FileUtils.rm_rf(File.dirname(output_path))
      
      runner = Tailwindcss::Compiler::Runner.new
      runner.call
      
      expect(Dir.exist?(File.dirname(output_path))).to be true
      expect(File.exist?(output_path)).to be true
    end
    
    it "processes all configured content paths" do
      runner = Tailwindcss::Compiler::Runner.new
      
      # Verify content paths are configured
      content_paths = Tailwindcss.resolve_setting(Tailwindcss.config.content)
      expect(content_paths).not_to be_empty
      expect(content_paths.any? { |p| p.to_s.include?("app/views") }).to be true
      expect(content_paths.any? { |p| p.to_s.include?("app/controllers") }).to be true
    end
  end
  
  describe "Caching Behavior" do
    it "caches extracted ASTs" do
      runner = Tailwindcss::Compiler::Runner.new
      runner.call
      
      # Cache should be created
      cache_file = File.join(cache_dir, "ast_cache.json")
      expect(File.exist?(cache_file)).to be true
      
      # Cache should contain our component files
      cache_content = JSON.parse(File.read(cache_file))
      expect(cache_content).to have_key(Rails.root.join("app/components/button_component.rb").to_s)
    end
    
    it "invalidates cache when file changes" do
      runner = Tailwindcss::Compiler::Runner.new
      runner.call
      
      cache_file = File.join(cache_dir, "ast_cache.json")
      original_cache = JSON.parse(File.read(cache_file))
      
      # Modify a component file
      sleep 0.1 # Ensure mtime changes
      File.write(test_file_path, <<~RUBY)
        class TestComponent
          include Tailwindcss::Helpers
          
          def test_style
            style(bg: :purple._(500), text: :white)
          end
        end
      RUBY
      
      # Run compiler again
      runner.call
      
      # Cache should be updated
      new_cache = JSON.parse(File.read(cache_file))
      expect(new_cache).to have_key(test_file_path.to_s)
      
      # Extract classes from new file
      extractor = Tailwindcss::Compiler::FileClassesExtractor.new
      classes = extractor.call(test_file_path.to_s)
      expect(classes).to include("bg-purple-500")
    end
    
    it "uses cached results for unchanged files" do
      runner = Tailwindcss::Compiler::Runner.new
      runner.call
      
      # Get initial cache
      cache = Tailwindcss::Compiler::AstCache.new
      component_path = Rails.root.join("app/components/button_component.rb").to_s
      
      # Record initial mtime
      initial_mtime = File.mtime(component_path)
      
      # Fetch from cache (should not yield)
      yielded = false
      result = cache.fetch(component_path) do
        yielded = true
        "new_value"
      end
      
      expect(yielded).to be false
      expect(result).not_to eq("new_value")
    end
  end
  
  describe "File Watching" do
    context "when watch_content is enabled" do
      before do
        Tailwindcss.configure do |config|
          config.watch_content = true
        end
      end
      
      after do
        Tailwindcss.configure do |config|
          config.watch_content = false
        end
      end
      
      it "sets up file watchers for content paths" do
        runner = Tailwindcss::Compiler::Runner.new
        
        # Runner should set up listeners
        expect(runner.instance_variable_get(:@listener)).not_to be_nil if Tailwindcss.config.watch_content
      end
    end
    
    context "when watch_content is disabled" do
      it "does not set up file watchers" do
        Tailwindcss.configure do |config|
          config.watch_content = false
        end
        
        runner = Tailwindcss::Compiler::Runner.new
        runner.call
        
        expect(runner.instance_variable_get(:@listener)).to be_nil
      end
    end
  end
  
  describe "Mode Switching" do
    context "in production mode" do
      before do
        allow(Tailwindcss).to receive(:production_mode?).and_return(true)
        allow(Tailwindcss).to receive(:development_mode?).and_return(false)
      end
      
      it "skips compilation" do
        # Clear any existing CSS file
        FileUtils.rm_f(output_path) if File.exist?(output_path)
        
        # Initialize should not compile in production
        Tailwindcss.init!
        
        # CSS file should not be created
        expect(File.exist?(output_path)).to be false
      end
      
      it "does not create cache directories" do
        FileUtils.rm_rf(cache_dir) if Dir.exist?(cache_dir)
        
        Tailwindcss.init!
        
        expect(Dir.exist?(cache_dir)).to be false
      end
    end
    
    context "in development mode" do
      before do
        allow(Tailwindcss).to receive(:production_mode?).and_return(false)
        allow(Tailwindcss).to receive(:development_mode?).and_return(true)
      end
      
      it "runs compilation" do
        Tailwindcss.init!
        
        # Should create cache directory
        expect(Dir.exist?(cache_dir)).to be true
      end
      
      it "allows manual compilation with compile_css!" do
        expect {
          Tailwindcss.compile_css!
        }.to output(/Recompiling Tailwindcss/).to_stdout_from_any_process
      end
    end
  end
  
  describe "Style Helpers Integration" do
    it "generates correct classes in controllers" do
      controller = PagesController.new
      
      # Test style generation
      button_style = controller.instance_eval do
        @button_style = style(bg: :blue, text: :white, p: 4, rounded: :lg)
      end
      
      expect(button_style).to include("bg-blue")
      expect(button_style).to include("text-white")
      expect(button_style).to include("p-4")
      expect(button_style).to include("rounded-lg")
    end
    
    it "handles style composition" do
      controller = PagesController.new
      
      base_style = controller.style(p: 4, rounded: :md)
      variant_style = controller.style(bg: :blue, text: :white)
      
      combined = Tailwindcss::Style.new(base_style).merge(variant_style).to_s
      
      expect(combined).to include("p-4")
      expect(combined).to include("rounded-md")
      expect(combined).to include("bg-blue")
      expect(combined).to include("text-white")
    end
  end
  
  describe "Error Handling" do
    it "handles syntax errors in Ruby files gracefully" do
      File.write(test_file_path, <<~RUBY)
        class BrokenComponent
          def broken_method
            style(bg: :blue # Missing closing parenthesis
          end
        end
      RUBY
      
      extractor = Tailwindcss::Compiler::FileClassesExtractor.new
      
      # Should not raise an error
      expect {
        classes = extractor.call(test_file_path.to_s)
        expect(classes).to eq([])
      }.not_to raise_error
    end
    
    it "handles malformed ERB templates" do
      erb_path = Rails.root.join("app/views/test.html.erb")
      File.write(erb_path, <<~ERB)
        <%= style(bg: :blue %>  <%# Missing closing parenthesis %>
        <div class="<%= @undefined_var %>">
          Content
        </div>
      ERB
      
      extractor = Tailwindcss::Compiler::FileClassesExtractor.new
      
      expect {
        classes = extractor.call(erb_path.to_s)
        # Should still extract what it can
        expect(classes).to include("bg-blue") if classes.any?
      }.not_to raise_error
      
      FileUtils.rm_f(erb_path)
    end
    
    it "handles missing files gracefully" do
      extractor = Tailwindcss::Compiler::FileClassesExtractor.new
      
      expect {
        classes = extractor.call("/non/existent/file.rb")
        expect(classes).to eq([])
      }.not_to raise_error
    end
  end
  
  describe "Performance" do
    it "processes multiple files efficiently" do
      # Create multiple test components
      10.times do |i|
        File.write(Rails.root.join("app/components/test_#{i}.rb"), <<~RUBY)
          class Test#{i}Component
            include Tailwindcss::Helpers
            
            def style_#{i}
              style(
                bg: :blue._(#{i}00),
                text: :white,
                p: #{i},
                m: #{i}
              )
            end
          end
        RUBY
      end
      
      start_time = Time.now
      runner = Tailwindcss::Compiler::Runner.new
      runner.call
      elapsed = Time.now - start_time
      
      # Should complete reasonably quickly (adjust threshold as needed)
      expect(elapsed).to be < 5.0
      
      # Clean up
      10.times do |i|
        FileUtils.rm_f(Rails.root.join("app/components/test_#{i}.rb"))
      end
    end
    
    it "benefits from caching on repeated runs" do
      runner = Tailwindcss::Compiler::Runner.new
      
      # First run - no cache
      start_time = Time.now
      runner.call
      first_run = Time.now - start_time
      
      # Second run - with cache
      start_time = Time.now
      runner.call
      second_run = Time.now - start_time
      
      # Second run should be faster (or at least not significantly slower)
      expect(second_run).to be <= first_run * 1.2
    end
  end
end