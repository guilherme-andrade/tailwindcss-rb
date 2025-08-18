# Test component for compiler integration
class ButtonComponent
  include Tailwindcss::Helpers
  
  attr_reader :variant, :size
  
  def initialize(variant: :primary, size: :md)
    @variant = variant
    @size = size
  end
  
  def style_classes
    base = style(
      px: size_config[:px],
      py: size_config[:py],
      rounded: :lg,
      font: :medium,
      transition: :colors,
      duration: 200
    )
    
    variant_styles = case variant
    when :primary
      style(bg: color_token(:blue, 500), text: :white, hover: { bg: color_token(:blue, 600) })
    when :secondary
      style(bg: color_token(:gray, 200), text: color_token(:gray, 800), hover: { bg: color_token(:gray, 300) })
    when :danger
      style(bg: color_token(:red, 500), text: :white, hover: { bg: color_token(:red, 600) })
    else
      style(bg: color_token(:gray, 100), text: color_token(:gray, 900))
    end
    
    "#{base} #{variant_styles}"
  end
  
  private
  
  def size_config
    case size
    when :sm
      { px: 3, py: 1 }
    when :lg
      { px: 6, py: 3 }
    else
      { px: 4, py: 2 }
    end
  end
end