# Test channel to ensure TailwindCSS compiler channel works
class TailwindChannel < ApplicationCable::Channel
  def subscribed
    stream_from "tailwind_updates"
  end
  
  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end