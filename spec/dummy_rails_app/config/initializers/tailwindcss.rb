# Configure TailwindCSS-RB for the Rails app
Tailwindcss.configure do |config|
  # Set mode based on Rails environment
  config.mode = Rails.env.production? ? :production : :development
  
  # Configure paths
  config.compiler.assets_path = Rails.root.join("app/assets/stylesheets")
  config.compiler.output_file_name = "tailwind"
  config.compiler.compile_classes_dir = Rails.root.join("tmp/tailwindcss")
  
  # Configure content paths
  config.content = [
    Rails.root.join("app/views/**/*.erb"),
    Rails.root.join("app/controllers/**/*.rb"),
    Rails.root.join("app/models/**/*.rb")
  ]
  
  # Set logger to Rails logger
  config.logger = Rails.logger
end