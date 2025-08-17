# frozen_string_literal: true

require "tailwindcss"
require "tailwindcss/compiler/file_classes_extractor"
require "tailwindcss/compiler/file_parser"
require "tailwindcss/compiler/hash_args_extractor"
require "tempfile"
require "fileutils"

RSpec.describe "Tailwindcss::Compiler Stress Tests" do
  let(:temp_dir) { Dir.mktmpdir }
  let(:extractor) { Tailwindcss::Compiler::FileClassesExtractor.new }
  let(:parser) { Tailwindcss::Compiler::FileParser.new }
  let(:hash_extractor) { Tailwindcss::Compiler::HashArgsExtractor.new }

  after do
    FileUtils.rm_rf(temp_dir)
  end

  describe "FileParser stress tests" do
    context "with malformed Ruby files" do
      it "handles files with syntax errors gracefully" do
        file = File.join(temp_dir, "broken.rb")
        File.write(file, "def broken_method\n  tailwind(bg: :red")

        expect { parser.call(file_path: file) }.not_to raise_error
        expect(parser.call(file_path: file)).to be_nil
      end

      it "handles files with unicode characters" do
        file = File.join(temp_dir, "unicode.rb")
        File.write(file, "# 你好世界\ndef method\n  tailwind(bg: :red, text: :white)\nend")

        ast = parser.call(file_path: file)
        expect(ast).not_to be_nil
      end

      it "handles deeply nested Ruby code" do
        file = File.join(temp_dir, "nested.rb")
        nested_code = "module A\n" \
                      "  class B\n" \
                      "    module C\n" \
                      "      class D\n" \
                      "        def method\n" \
                      "          tailwind(bg: :blue)\n" \
                      "        end\n" \
                      "      end\n" \
                      "    end\n" \
                      "  end\n" \
                      "end"
        File.write(file, nested_code)

        ast = parser.call(file_path: file)
        expect(ast).not_to be_nil
      end

      it "handles files with mixed encodings" do
        file = File.join(temp_dir, "mixed.rb")
        File.write(file, "# encoding: UTF-8\n# café\ndef método\n  tailwind(bg: :green)\nend")

        ast = parser.call(file_path: file)
        expect(ast).not_to be_nil
      end
    end

    context "with complex ERB files" do
      it "handles ERB with multiple Ruby blocks" do
        file = File.join(temp_dir, "complex.html.erb")
        erb_content = <<~ERB
          <div class="<%= tailwind(bg: :red) %>">
            <% if condition %>
              <span class="<%= tailwind(text: :white) %>">Text</span>
            <% end %>
            <%= content_tag :div, class: tailwind(p: 4) do %>
              Content
            <% end %>
          </div>
        ERB
        File.write(file, erb_content)

        ast = parser.call(file_path: file)
        expect(ast).not_to be_nil
      end

      it "handles ERB with nested quotes and special characters" do
        file = File.join(temp_dir, "special.html.erb")
        erb_content = <<~ERB
          <div class='<%= tailwind(bg: "[url(\\"image.png\\")]") %>'>
            <%= tailwind(content: '["\\'\\""]') %>
          </div>
        ERB
        File.write(file, erb_content)

        ast = parser.call(file_path: file)
        expect(ast).not_to be_nil
      end

      it "handles ERB embedded in Ruby files" do
        file = File.join(temp_dir, "embedded.rb")
        ruby_content = <<~RUBY
          def render_template
            <<~ERB
              <div class="<%= tailwind(bg: :blue) %>">
                Content
              </div>
            ERB
          end
        RUBY
        File.write(file, ruby_content)

        ast = parser.call(file_path: file)
        expect(ast).not_to be_nil
      end
    end
  end

  describe "HashArgsExtractor stress tests" do
    context "with complex hash arguments" do
      it "extracts deeply nested modifiers" do
        code = <<~RUBY
          tailwind(
            bg: :white,
            _hover: {
              bg: :gray,
              _focus: {
                bg: :blue,
                _active: {
                  bg: :indigo,
                  _disabled: {
                    bg: :gray
                  }
                }
              }
            }
          )
        RUBY

        file = File.join(temp_dir, "nested_modifiers.rb")
        File.write(file, code)

        classes = extractor.call(file_path: file)
        expect(classes).to include("bg-white")
        expect(classes).to include("hover:bg-gray")
        expect(classes).to include("hover:focus:bg-blue")
        expect(classes).to include("hover:focus:active:bg-indigo")
        expect(classes).to include("hover:focus:active:disabled:bg-gray")
      end

      it "handles multiple tailwind calls in one file" do
        code = <<~RUBY
          class Component
            def style1
              tailwind(bg: :red, p: 4)
            end
          #{"  "}
            def style2
              tw(mt: 2, text: :white)
            end
          #{"  "}
            def style3
              tailwind(
                border: true,
                rounded: :lg,
                shadow: :xl
              )
            end
          end
        RUBY

        file = File.join(temp_dir, "multiple_calls.rb")
        File.write(file, code)

        classes = extractor.call(file_path: file)
        expect(classes).to include("bg-red", "p-4")
        expect(classes).to include("mt-2", "text-white")
        expect(classes).to include("border", "rounded-lg", "shadow-xl")
      end

      it "handles dynamic color scheme tokens" do
        code = <<~RUBY
          tailwind(
            bg: color_scheme_token(:primary),
            text: color_scheme_token(:secondary, 300),
            border: color_token(:indigo, 500)
          )
        RUBY

        file = File.join(temp_dir, "color_tokens.rb")
        File.write(file, code)

        classes = extractor.call(file_path: file)
        expect(classes).to include("bg-purple-500") # Default primary
        expect(classes).to include("text-indigo-300") # Default secondary
        expect(classes).to include("border-indigo-500")
      end

      it "handles arbitrary values with special characters" do
        code = <<~RUBY
          tailwind(
            bg: "[url('/path/to/image.jpg')]",
            content: '["\\'\\"\\\\"]',
            width: "[calc(100%-2rem)]",
            grid_template_columns: "[1fr_2fr_1fr]"
          )
        RUBY

        file = File.join(temp_dir, "arbitrary.rb")
        File.write(file, code)

        classes = extractor.call(file_path: file)
        expect(classes.any? { |c| c.include?("[url('/path/to/image.jpg')]") }).to be true
        expect(classes.any? { |c| c.include?("[calc(100%-2rem)]") }).to be true
      end
    end

    context "with edge cases" do
      it "handles empty tailwind calls" do
        code = "tailwind()"
        file = File.join(temp_dir, "empty.rb")
        File.write(file, code)

        classes = extractor.call(file_path: file)
        expect(classes).to eq([])
      end

      it "handles boolean values correctly" do
        code = <<~RUBY
          tailwind(
            border: true,
            hidden: false,
            flex: true,
            inline: false
          )
        RUBY

        file = File.join(temp_dir, "booleans.rb")
        File.write(file, code)

        classes = extractor.call(file_path: file)
        expect(classes).to include("border")
        expect(classes).to include("flex")
        expect(classes).not_to include("hidden")
        expect(classes).not_to include("inline")
      end

      it "handles numeric values of all types" do
        code = <<~RUBY
          tailwind(
            p: 0,
            m: 0.5,
            gap: 1.5,
            text: 2,
            w: 96,
            h: "1/2",
            top: "100",
            z: -10
          )
        RUBY

        file = File.join(temp_dir, "numbers.rb")
        File.write(file, code)

        classes = extractor.call(file_path: file)
        expect(classes).to include("p-0")
        expect(classes).to include("m-0.5")
        expect(classes).to include("gap-1.5")
        expect(classes).to include("text-2")
        expect(classes).to include("w-96")
      end

      it "handles method calls as values gracefully" do
        code = <<~RUBY
          tailwind(
            bg: some_method(),
            text: @instance_var,
            p: CONSTANT
          )
        RUBY

        file = File.join(temp_dir, "methods.rb")
        File.write(file, code)

        # Should not crash, but won't extract these dynamic values
        expect { extractor.call(file_path: file) }.not_to raise_error
      end
    end
  end

  describe "FileClassesExtractor with caching stress tests" do
    it "handles rapid file modifications" do
      file = File.join(temp_dir, "rapid.rb")

      # Initial write
      File.write(file, "tailwind(bg: :red)")
      classes1 = extractor.call(file_path: file)
      expect(classes1).to include("bg-red")

      # Rapid modifications
      10.times do |i|
        sleep(0.01) # Ensure mtime changes
        File.write(file, "tailwind(bg: :blue, p: #{i})")
        classes = extractor.call(file_path: file)
        expect(classes).to include("bg-blue", "p-#{i}")
      end
    end

    it "handles many files without memory issues" do
      # Create many files
      100.times do |i|
        file = File.join(temp_dir, "file_#{i}.rb")
        File.write(file, "tailwind(bg: :red, p: #{i % 10})")

        classes = extractor.call(file_path: file)
        expect(classes).not_to be_empty
      end

      # Cache should still be functional
      test_file = File.join(temp_dir, "file_0.rb")
      classes = extractor.call(file_path: test_file)
      expect(classes).to include("bg-red", "p-0")
    end

    it "handles concurrent access patterns" do
      files = 5.times.map do |i|
        file = File.join(temp_dir, "concurrent_#{i}.rb")
        File.write(file, "tailwind(bg: :green, mt: #{i})")
        file
      end

      # Simulate concurrent-like access
      results = []
      files.each do |file|
        results << extractor.call(file_path: file)
      end

      results.each_with_index do |classes, i|
        expect(classes).to include("bg-green", "mt-#{i}")
      end
    end
  end

  describe "Complex real-world scenarios" do
    it "handles a ViewComponent with multiple style methods" do
      code = <<~RUBY
        class CardComponent < ViewComponent::Base
          include Tailwindcss::Helpers
        #{"  "}
          def base_style
            tailwind(
              bg: :white,
              rounded: :lg,
              shadow: :md,
              p: 6,
              _dark: {
                bg: :gray,
                text: :white
              }
            )
          end
        #{"  "}
          def header_style
            tw(
              text: :xl,
              font: :bold,
              mb: 4,
              _hover: { text: :blue }
            )
          end
        #{"  "}
          def footer_style
            tailwind(**dark(bg: :gray, text: :gray))
          end
        #{"  "}
          private
        #{"  "}
          def variant_styles
            {
              primary: tailwind(border: 2, border_blue: 500),
              secondary: tw(border: 1, border_gray: 300)
            }
          end
        end
      RUBY

      file = File.join(temp_dir, "component.rb")
      File.write(file, code)

      classes = extractor.call(file_path: file)
      expect(classes).to include("bg-white", "rounded-lg", "shadow-md", "p-6")
      expect(classes).to include("dark:bg-gray", "dark:text-white")
      expect(classes).to include("text-xl", "font-bold", "mb-4")
      expect(classes).to include("hover:text-blue")
      expect(classes).to include("border-2", "border-blue-500")
      expect(classes).to include("border-1", "border-gray-300")
    end

    it "handles a complex ERB template with conditionals and loops" do
      erb_content = <<~ERB
        <div class="<%= tailwind(container: true, mx: :auto, px: 4) %>">
          <% @items.each_with_index do |item, index| %>
            <div class="<%= tailwind(
              p: 4,
              mb: 4,
              bg: :white,
              _hover: { bg: :blue, text: :white }
            ) %>">
              <%= item.name %>
            </div>
          <% end %>
        #{"  "}
          <div class="<%= tailwind(p: 4, mb: 0, bg: :gray) %>">
            Last item
          </div>
        #{"  "}
          <% if @show_footer %>
            <footer class="<%= tw(mt: 8, pt: 4, border_t: true) %>">
              Footer content
            </footer>
          <% end %>
        </div>
      ERB

      file = File.join(temp_dir, "template.html.erb")
      File.write(file, erb_content)

      classes = extractor.call(file_path: file)
      expect(classes).to include("container", "mx-auto", "px-4")
      expect(classes).to include("p-4", "mb-4", "mb-0")
      expect(classes).to include("bg-white", "bg-gray")
      expect(classes).to include("hover:bg-blue", "hover:text-white")
      expect(classes).to include("mt-8", "pt-4", "border-t")
    end

    it "handles mixed Ruby and ERB in a single file" do
      code = <<~RUBY
        class PageBuilder
          def render
            html = <<~HTML
              <div class="\#{tailwind(bg: :white, p: 4)}">
                Content
              </div>
            HTML
        #{"    "}
            erb = <<~ERB
              <div class="<%= tailwind(mt: 2, mb: 4) %>">
                <%= tailwind(text: :gray, font: :medium) %>
              </div>
            ERB
        #{"    "}
            haml_style = tailwind(
              display: :flex,
              items: :center,
              justify: :between
            )
          end
        end
      RUBY

      file = File.join(temp_dir, "mixed.rb")
      File.write(file, code)

      classes = extractor.call(file_path: file)
      expect(classes).to include("bg-white", "p-4")
      expect(classes).to include("mt-2", "mb-4")
      expect(classes).to include("text-gray", "font-medium")
      expect(classes).to include("flex", "items-center", "justify-between")
    end
  end

  describe "Performance characteristics" do
    it "handles very long argument lists efficiently" do
      args = (1..100).map { |i| "p#{i}: #{i}" }.join(", ")
      code = "tailwind(#{args})"

      file = File.join(temp_dir, "long_args.rb")
      File.write(file, code)

      start_time = Time.now
      classes = extractor.call(file_path: file)
      duration = Time.now - start_time

      expect(duration).to be < 1.0 # Should complete in under 1 second
      expect(classes).not_to be_empty
    end

    it "benefits from caching on repeated calls" do
      file = File.join(temp_dir, "cached.rb")
      File.write(file, "tailwind(bg: :red, p: 4, mt: 2, rounded: :lg, shadow: :xl)")

      # First call - parses file
      start1 = Time.now
      extractor.call(file_path: file)
      duration1 = Time.now - start1

      # Second call - should use cache
      start2 = Time.now
      extractor.call(file_path: file)
      duration2 = Time.now - start2

      # Cached call should be significantly faster
      expect(duration2).to be < (duration1 * 0.5)
    end
  end
end
