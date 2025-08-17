# frozen_string_literal: true

require "tailwindcss"
require "json"

module Tailwindcss
  module Installers
    class ConfigFileGenerator
      def call
        File.write("./tailwind.config.js", tailwind_config_file_content)
      end

      private

      def content
        value = Tailwindcss.config.content
        return value unless value.respond_to?(:call)

        value.call
      end

      def tailwind_config_file_content
        content_option = (content + ["./tmp/tailwindcss"]).map { "#{_1}/**/*" }
        <<~TAILWIND_CONFIG
          /** @type {import('tailwindcss').Config} */

          /** this file was generated automatically, please do not modify it directly!! */
          /** instead change your tailwindcss-rb config and run `bundle exec rake tailwindcss:generate_config_file` */

          export default {
            content: #{content_option.to_json},
            prefix: '#{Tailwindcss.config.prefix}',
            #{Tailwindcss.config.tailwind_config_overrides.call.map { |k, v| "#{k}: #{v}," }.join("\n")}
          }
        TAILWIND_CONFIG
      end
    end
  end
end
