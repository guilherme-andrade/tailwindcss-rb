require "spec_helper"
require "tailwindcss/compiler/magic_comment_extractor"

RSpec.describe Tailwindcss::Compiler::MagicCommentExtractor do
  let(:extractor) { described_class.new }
  
  describe "#call" do
    context "with Ruby files" do
      it "extracts classes from single line @tw-whitelist comments" do
        content = <<~RUBY
          class MyComponent
            # @tw-whitelist bg-blue-500 text-white hover:bg-blue-600
            def render
              "Hello"
            end
          end
        RUBY
        
        result = extractor.call(content)
        expect(result).to eq(["bg-blue-500", "text-white", "hover:bg-blue-600"])
      end
      
      it "extracts classes from multiple @tw-whitelist comments" do
        content = <<~RUBY
          class ButtonComponent
            # @tw-whitelist bg-primary-500 bg-primary-600
            # @tw-whitelist hover:bg-primary-700 text-white
            # @tw-whitelist border-primary-500
            
            def render
              # Regular comment
              "Button"
            end
          end
        RUBY
        
        result = extractor.call(content)
        expect(result).to contain_exactly(
          "bg-primary-500", "bg-primary-600", 
          "hover:bg-primary-700", "text-white",
          "border-primary-500"
        )
      end
      
      it "handles indented comments" do
        content = <<~RUBY
          class Component
            def method
              # @tw-whitelist px-4 py-2
              something
            end
          end
        RUBY
        
        result = extractor.call(content)
        expect(result).to eq(["px-4", "py-2"])
      end
      
      it "ignores regular comments" do
        content = <<~RUBY
          # This is a regular comment
          # @tw-ignore this should not be extracted
          # tw-whitelist without @ should not work
          class Component
          end
        RUBY
        
        result = extractor.call(content)
        expect(result).to be_empty
      end
      
      it "handles complex Tailwind classes" do
        content = <<~RUBY
          # @tw-whitelist sm:px-4 md:px-6 lg:px-8 hover:bg-gradient-to-r focus:ring-2 focus:ring-offset-2
        RUBY
        
        result = extractor.call(content)
        expect(result).to eq([
          "sm:px-4", "md:px-6", "lg:px-8", 
          "hover:bg-gradient-to-r", "focus:ring-2", "focus:ring-offset-2"
        ])
      end
    end
  end
  
  describe "#extract_from_erb" do
    it "extracts from Ruby code blocks in ERB" do
      content = <<~ERB
        <div class="container">
          <% # @tw-whitelist bg-red-500 text-white %>
          <%= render_component %>
        </div>
      ERB
      
      result = extractor.extract_from_erb(content)
      expect(result).to eq(["bg-red-500", "text-white"])
    end
    
    it "extracts from HTML comments in ERB" do
      content = <<~ERB
        <!-- @tw-whitelist bg-green-500 hover:bg-green-600 -->
        <div>
          Content
        </div>
      ERB
      
      result = extractor.extract_from_erb(content)
      expect(result).to eq(["bg-green-500", "hover:bg-green-600"])
    end
    
    it "combines classes from both Ruby and HTML comments" do
      content = <<~ERB
        <!-- @tw-whitelist mx-auto container -->
        <div>
          <% # @tw-whitelist px-4 py-2 %>
          <%= content %>
        </div>
        <!-- @tw-whitelist flex items-center -->
      ERB
      
      result = extractor.extract_from_erb(content)
      expect(result).to contain_exactly(
        "mx-auto", "container", "px-4", "py-2", "flex", "items-center"
      )
    end
  end
end