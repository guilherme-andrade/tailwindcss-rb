module Tailwindcss
  module Compiler
    class Channel < ActionCable::Channel::Base

      def subscribed
        stream_from "compiler_channel"
      end

      def self.broadcast_css_changed
        css_path = asset_url_for_css
        ActionCable.server.broadcast("compiler_channel", {css_path:})
      end
      
      private
      
      def self.asset_url_for_css
        output_file_name = Tailwindcss.resolve_setting(Tailwindcss.config.compiler.output_file_name)
        css_file = "#{output_file_name}.css"
        
        if defined?(Rails) && Rails.respond_to?(:application) && Rails.application.respond_to?(:assets)
          # Use Rails asset helpers if available
          Rails.application.routes.url_helpers.asset_url(css_file)
        else
          # Otherwise use relative path from assets directory
          "/assets/#{css_file}"
        end
      end
    end
  end
end
