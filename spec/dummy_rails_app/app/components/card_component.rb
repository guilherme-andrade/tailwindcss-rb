class CardComponent
  include Tailwindcss::Helpers
  
  def wrapper_classes
    style(
      bg: :white,
      rounded: :xl,
      shadow: :lg,
      p: 6,
      border: true,
      border_color: color_token(:gray, 200)
    )
  end
  
  def header_classes
    style(
      text: :xl,
      font: :bold,
      mb: 4,
      text_color: color_token(:gray, 900)
    )
  end
  
  def body_classes
    style(
      text: :base,
      text_color: color_token(:gray, 600),
      leading: :relaxed
    )
  end
  
  def footer_classes
    style(
      mt: 6,
      pt: 4,
      border_t: true,
      border_color: color_token(:gray, 100),
      flex: true,
      justify: :between,
      items: :center
    )
  end
  
  # Test dark mode
  def dark_wrapper_classes
    dark(
      bg: color_token(:gray, 800),
      border_color: color_token(:gray, 700),
      text: :white
    )
  end
  
  # Test responsive design
  def responsive_padding
    at(:sm, p: 4) + at(:md, p: 6) + at(:lg, p: 8)
  end
end