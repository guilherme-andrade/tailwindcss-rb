module Tailwindcss
  module Compiler
    class Channel < ActionCable::Channel::Base

      def subscribed
        stream_from "compiler_channel"
      end

      def self.broadcast_css_changed
        return unless defined?(ActionCable)
        
        begin
          # Check if ActionCable server is properly configured
          return unless ActionCable.server
          
          # Early return if ActionCable config is not available
          # This happens when ActionCable is defined but not configured
          if ActionCable.server.config.respond_to?(:cable)
            return unless ActionCable.server.config.cable
          end
          
          # Ensure ActionCable has a logger to prevent internal errors
          # Works with multiple Rails versions (6.0, 6.1, 7.0, 7.1+)
          if ActionCable.server
            # Rails 7.1+ uses config.logger
            if ActionCable.server.config.respond_to?(:logger=) && !ActionCable.server.config.logger
              ActionCable.server.config.logger = Tailwindcss.logger || Logger.new(nil)
            # Rails 6.x and 7.0 use server.logger
            elsif ActionCable.server.respond_to?(:logger=) && !ActionCable.server.logger
              ActionCable.server.logger = Tailwindcss.logger || Logger.new(nil)
            end
          end
          
          css_path = asset_url_for_css
          ActionCable.server.broadcast("compiler_channel", {css_path:})
        rescue => e
          # Log the error if logger is available, otherwise silently fail
          # ActionCable might not be fully configured in some environments
          Tailwindcss.log_warn "Failed to broadcast CSS change: #{e.message}"
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
