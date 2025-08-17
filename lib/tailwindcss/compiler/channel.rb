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
        
        if defined?(Rails) && Rails.application
          # Use ActionController::Base helper which is available in Rails context
          helpers = ActionController::Base.helpers
          if helpers.respond_to?(:asset_path)
            helpers.asset_path(css_file)
          else
            "/assets/#{css_file}"
          end
        else
          "/assets/#{css_file}"
        end
      end
    end
  end
end
