class PagesController < ApplicationController
  include Tailwindcss::Helpers
  
  def index
    @button_style = style(bg: :blue, text: :white, p: 4, rounded: :lg)
    @card_style = style(
      bg: :white,
      shadow: :lg,
      rounded: :xl,
      p: 6
    )
  end
  
  def show
    @dynamic_style = style(
      bg: params[:bg] || :gray,
      text: params[:text] || :black,
      p: 4
    )
  end
end