require "tailwindcss/installers/config_file_generator"

module Tailwindcss
  class Installer
    def call
      Installers::ConfigFileGenerator.new.call
      install_packages
    end

    private

    def install_packages
      system("yarn init -y") unless File.exist?('./package.json')
      system("yarn add -D tailwindcss autoprefixer postcss")
    end
  end
end
