require "rails_helper"

RSpec.describe "Compiler Integration", type: :feature do
  describe "production/development mode" do
    context "in development mode" do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
        Tailwindcss.configure do |config|
          config.mode = :development
        end
      end
      
      it "runs the compiler" do
        expect(Tailwindcss.development_mode?).to be true
        expect(Tailwindcss.production_mode?).to be false
      end
    end
    
    context "in production mode" do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
        Tailwindcss.configure do |config|
          config.mode = :production
        end
      end
      
      it "skips the compiler" do
        expect(Tailwindcss.production_mode?).to be true
        expect(Tailwindcss.development_mode?).to be false
      end
    end
  end
  
  describe "file watching" do
    it "watches configured content paths" do
      content_paths = Tailwindcss.resolve_setting(Tailwindcss.config.content)
      expect(content_paths).not_to be_empty
      
      content_paths.each do |path|
        expect(path).to be_a(Pathname)
      end
    end
  end
  
  describe "style helpers in controllers" do
    it "makes style helpers available in controllers" do
      controller = PagesController.new
      expect(controller).to respond_to(:style)
      
      # Test style generation
      style = controller.style(bg: :blue, text: :white, p: 4)
      expect(style).to be_a(String)
      expect(style).to include("bg-blue")
      expect(style).to include("text-white")
      expect(style).to include("p-4")
    end
  end
end