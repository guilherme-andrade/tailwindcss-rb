
namespace :tailwindcss do
  desc "Generate TailwindCSS configuration file"
  task :install do
    require "tailwindcss/installer"
    Tailwindcss::Installer.new.call
  end

  desc "Generate config file"
  task :generate_config_file do
    require "tailwindcss/installers/config_file_generator"
    Tailwindcss::Installers::ConfigFileGenerator.new.call
  end

  desc "Compile TailwindCSS"
  task :compile do
    require "tailwindcss/compiler/runner"
    Tailwindcss::Compiler::Runner.new.call
  end

  namespace :compile do
    desc "Compile TailwindCSS and watch for file changes"
    task :watch do
      require "tailwindcss/compiler/runner"
      Tailwindcss::Compiler::Runner.new(watch: true).call
    end
  end
end
