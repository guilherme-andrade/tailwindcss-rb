module Tailwindcss
  module Compiler
    class Channel < ActionCable::Channel::Base

      def subscribed
        stream_from "compiler_channel"
      end

      def self.broadcast_css_changed
        css_path = Tailwindcss.tailwind_css_file_path
        ActionCable.server.broadcast("compiler_channel", {css_path:})
      end
    end
  end
end
