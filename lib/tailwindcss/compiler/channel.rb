module Tailwindcss
  module Compiler
    class Channel < ActionCable::Channel::Base

      def subscribed
        stream_from "compiler_channel"
      end

      def self.broadcast_css_changed
        return unless defined?(ActionCable) && ActionCable.server
        
        css_path = asset_url_for_css
        begin
          ActionCable.server.broadcast("compiler_channel", {css_path:})
        rescue => e
          # Log the error if logger is available, otherwise silently fail
          # ActionCable might not be fully configured in some environments
          if Tailwindcss.respond_to?(:logger) && Tailwindcss.logger
            Tailwindcss.logger.warn "Failed to broadcast CSS change: #{e.message}"
          end
        end
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
