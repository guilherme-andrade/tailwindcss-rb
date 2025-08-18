require "rails_helper"

RSpec.describe "Rails View Integration", type: :integration do
  let(:extractor) { Tailwindcss::Compiler::FileClassesExtractor.new }
  
  describe "ERB Template Processing" do
    it "extracts classes from ERB templates" do
      erb_content = <<~ERB
        <div class="<%= style(bg: :blue._(500), p: 4, rounded: :lg) %>">
          <h1 class="<%= style(text: :xl, font: :bold, mb: 2) %>">Title</h1>
          <p class="<%= style(text: :gray._(600), leading: :relaxed) %>">Content</p>
        </div>
      ERB
      
      erb_path = Rails.root.join("app/views/test_template.html.erb")
      File.write(erb_path, erb_content)
      
      classes = extractor.call(erb_path.to_s)
      
      expect(classes).to include("bg-blue-500")
      expect(classes).to include("p-4")
      expect(classes).to include("rounded-lg")
      expect(classes).to include("text-xl")
      expect(classes).to include("font-bold")
      expect(classes).to include("mb-2")
      expect(classes).to include("text-gray-600")
      expect(classes).to include("leading-relaxed")
      
      FileUtils.rm_f(erb_path)
    end
    
    it "handles ERB with Ruby conditionals" do
      erb_content = <<~ERB
        <% if user_signed_in? %>
          <div class="<%= style(bg: :green._(100), border: :green._(500)) %>">
            Welcome back!
          </div>
        <% else %>
          <div class="<%= style(bg: :yellow._(100), border: :yellow._(500)) %>">
            Please sign in
          </div>
        <% end %>
      ERB
      
      erb_path = Rails.root.join("app/views/conditional_template.html.erb")
      File.write(erb_path, erb_content)
      
      classes = extractor.call(erb_path.to_s)
      
      # Should extract classes from both branches
      expect(classes).to include("bg-green-100")
      expect(classes).to include("border-green-500")
      expect(classes).to include("bg-yellow-100")
      expect(classes).to include("border-yellow-500")
      
      FileUtils.rm_f(erb_path)
    end
    
    it "handles ERB with loops" do
      erb_content = <<~ERB
        <% items.each_with_index do |item, index| %>
          <div class="<%= style(
            p: index.even? ? 4 : 2,
            bg: index.zero? ? :blue._(100) : :gray._(50),
            border_b: true
          ) %>">
            <%= item.name %>
          </div>
        <% end %>
      ERB
      
      erb_path = Rails.root.join("app/views/loop_template.html.erb")
      File.write(erb_path, erb_content)
      
      classes = extractor.call(erb_path.to_s)
      
      expect(classes).to include("p-4")
      expect(classes).to include("p-2")
      expect(classes).to include("bg-blue-100")
      expect(classes).to include("bg-gray-50")
      expect(classes).to include("border-b")
      
      FileUtils.rm_f(erb_path)
    end
    
    it "handles partials with local variables" do
      erb_content = <<~ERB
        <%= render partial: 'components/button', locals: {
          variant: :primary,
          size: :lg,
          content: 'Click me'
        } %>
        
        <div class="<%= style(mt: 4, space_y: 2) %>">
          <%= render partial: 'components/card', locals: {
            title: 'Card Title',
            footer: 'Card Footer'
          } do %>
            Card content
          <% end %>
        </div>
      ERB
      
      erb_path = Rails.root.join("app/views/partial_test.html.erb")
      File.write(erb_path, erb_content)
      
      classes = extractor.call(erb_path.to_s)
      
      expect(classes).to include("mt-4")
      expect(classes).to include("space-y-2")
      
      FileUtils.rm_f(erb_path)
    end
  end
  
  describe "Helper Method Integration" do
    it "extracts classes from helper methods in views" do
      erb_content = <<~ERB
        <div class="<%= dark(bg: :gray._(900), text: :white) %>">
          Dark mode content
        </div>
        
        <div class="<%= at(:md, display: :flex, gap: 4) %>">
          Responsive content
        </div>
        
        <button class="<%= style(p: 2) + hover(bg: :blue._(100)) %>">
          Hover me
        </button>
      ERB
      
      erb_path = Rails.root.join("app/views/helper_test.html.erb")
      File.write(erb_path, erb_content)
      
      classes = extractor.call(erb_path.to_s)
      
      expect(classes).to include("dark:bg-gray-900")
      expect(classes).to include("dark:text-white")
      expect(classes).to include("md:flex")
      expect(classes).to include("md:gap-4")
      expect(classes).to include("p-2")
      expect(classes).to include("hover:bg-blue-100")
      
      FileUtils.rm_f(erb_path)
    end
    
    it "handles style composition in views" do
      erb_content = <<~ERB
        <%
          base_style = style(p: 4, rounded: :md, transition: :all)
          primary_style = style(bg: :blue._(500), text: :white)
          secondary_style = style(bg: :gray._(200), text: :gray._(800))
        %>
        
        <button class="<%= base_style + primary_style %>">
          Primary Button
        </button>
        
        <button class="<%= base_style + secondary_style %>">
          Secondary Button
        </button>
      ERB
      
      erb_path = Rails.root.join("app/views/composition_test.html.erb")
      File.write(erb_path, erb_content)
      
      classes = extractor.call(erb_path.to_s)
      
      expect(classes).to include("p-4")
      expect(classes).to include("rounded-md")
      expect(classes).to include("transition-all")
      expect(classes).to include("bg-blue-500")
      expect(classes).to include("text-white")
      expect(classes).to include("bg-gray-200")
      expect(classes).to include("text-gray-800")
      
      FileUtils.rm_f(erb_path)
    end
  end
  
  describe "Rails-specific Patterns" do
    it "handles form helpers with Tailwind classes" do
      erb_content = <<~ERB
        <%= form_with model: @user, html: { class: style(space_y: 4) } do |form| %>
          <div class="<%= style(mb: 4) %>">
            <%= form.label :name, class: style(block: true, text: :sm, font: :medium, mb: 2) %>
            <%= form.text_field :name, class: style(
              w: :full,
              px: 3,
              py: 2,
              border: true,
              border_color: :gray._(300),
              rounded: :md,
              focus: { ring: 2, ring_color: :blue._(500) }
            ) %>
          </div>
        <% end %>
      ERB
      
      erb_path = Rails.root.join("app/views/form_test.html.erb")
      File.write(erb_path, erb_content)
      
      classes = extractor.call(erb_path.to_s)
      
      expect(classes).to include("space-y-4")
      expect(classes).to include("mb-4")
      expect(classes).to include("block")
      expect(classes).to include("text-sm")
      expect(classes).to include("font-medium")
      expect(classes).to include("w-full")
      expect(classes).to include("px-3")
      expect(classes).to include("py-2")
      expect(classes).to include("border")
      expect(classes).to include("border-gray-300")
      expect(classes).to include("rounded-md")
      expect(classes).to include("focus:ring-2")
      expect(classes).to include("focus:ring-blue-500")
      
      FileUtils.rm_f(erb_path)
    end
    
    it "handles link_to helpers with Tailwind classes" do
      erb_content = <<~ERB
        <%= link_to "Home", root_path, class: style(
          text: :blue._(600),
          underline: true,
          hover: { text: :blue._(800) }
        ) %>
        
        <%= button_to "Delete", item_path(@item), method: :delete,
          class: style(
            bg: :red._(500),
            text: :white,
            px: 4,
            py: 2,
            rounded: :md,
            hover: { bg: :red._(600) }
          ),
          data: { confirm: "Are you sure?" }
        %>
      ERB
      
      erb_path = Rails.root.join("app/views/link_test.html.erb")
      File.write(erb_path, erb_content)
      
      classes = extractor.call(erb_path.to_s)
      
      expect(classes).to include("text-blue-600")
      expect(classes).to include("underline")
      expect(classes).to include("hover:text-blue-800")
      expect(classes).to include("bg-red-500")
      expect(classes).to include("text-white")
      expect(classes).to include("px-4")
      expect(classes).to include("py-2")
      expect(classes).to include("rounded-md")
      expect(classes).to include("hover:bg-red-600")
      
      FileUtils.rm_f(erb_path)
    end
    
    it "handles turbo frame tags with Tailwind classes" do
      erb_content = <<~ERB
        <%= turbo_frame_tag "user_profile", class: style(
          border: true,
          border_color: :gray._(200),
          rounded: :lg,
          p: 6,
          bg: :white,
          shadow: :sm
        ) do %>
          <div class="<%= style(space_y: 4) %>">
            Content here
          </div>
        <% end %>
      ERB
      
      erb_path = Rails.root.join("app/views/turbo_test.html.erb")
      File.write(erb_path, erb_content)
      
      classes = extractor.call(erb_path.to_s)
      
      expect(classes).to include("border")
      expect(classes).to include("border-gray-200")
      expect(classes).to include("rounded-lg")
      expect(classes).to include("p-6")
      expect(classes).to include("bg-white")
      expect(classes).to include("shadow-sm")
      expect(classes).to include("space-y-4")
      
      FileUtils.rm_f(erb_path)
    end
  end
  
  describe "Error Handling in Views" do
    it "handles undefined variables gracefully" do
      erb_content = <<~ERB
        <div class="<%= style(bg: undefined_color, p: 4) %>">
          <%= undefined_variable %>
        </div>
      ERB
      
      erb_path = Rails.root.join("app/views/error_test.html.erb")
      File.write(erb_path, erb_content)
      
      expect {
        classes = extractor.call(erb_path.to_s)
        # Should still extract what it can
        expect(classes).to include("p-4") if classes.any?
      }.not_to raise_error
      
      FileUtils.rm_f(erb_path)
    end
    
    it "handles syntax errors in ERB" do
      erb_content = <<~ERB
        <div class="<%= style(bg: :blue._(500 %>">  <%# Missing closing parenthesis %>
          Content
        </div>
      ERB
      
      erb_path = Rails.root.join("app/views/syntax_error_test.html.erb")
      File.write(erb_path, erb_content)
      
      expect {
        extractor.call(erb_path.to_s)
      }.not_to raise_error
      
      FileUtils.rm_f(erb_path)
    end
  end
end