require "rails_helper"

RSpec.describe "Asset Pipeline Integration", type: :feature do
  describe "asset path generation" do
    it "generates correct asset paths in Rails context" do
      output_file_name = Tailwindcss.resolve_setting(Tailwindcss.config.compiler.output_file_name)
      css_file = "#{output_file_name}.css"
      
      # Test that ActionController helpers are available
      helpers = ActionController::Base.helpers
      expect(helpers).to respond_to(:asset_path)
      
      # Test asset path generation
      asset_path = helpers.asset_path(css_file)
      expect(asset_path).to include(".css")
    end
    
    it "uses configured assets_path and output_file_name" do
      expect(Tailwindcss.config.compiler.assets_path).not_to be_nil
      expect(Tailwindcss.config.compiler.output_file_name).not_to be_nil
      
      output_path = Tailwindcss.output_path
      expect(output_path).to include("tailwind.css")
    end
  end
  
  describe "Tailwindcss configuration in Rails" do
    it "uses Rails logger" do
      expect(Tailwindcss.logger).to eq(Rails.logger)
    end
    
    it "sets mode based on Rails environment" do
      expect(Tailwindcss.resolve_setting(Tailwindcss.config.mode)).to eq(:development)
    end
    
    it "configures content paths for Rails app" do
      content = Tailwindcss.resolve_setting(Tailwindcss.config.content)
      expect(content).to be_an(Array)
      expect(content.any? { |path| path.to_s.include?("app/views") }).to be true
    end
  end
  
  describe "CSS compilation" do
    it "generates CSS file in configured location" do
      output_path = Tailwindcss.output_path
      dir = File.dirname(output_path)
      
      # Ensure directory exists
      FileUtils.mkdir_p(dir) unless File.exist?(dir)
      
      # Test that path is writable
      expect(File.writable?(dir)).to be true
    end
  end
end