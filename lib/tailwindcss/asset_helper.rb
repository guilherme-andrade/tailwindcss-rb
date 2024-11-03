module Tailwindcss
  module AssetHelper
    include ActionView::Helpers::AssetTagHelper

    extend self

    def tailwind_stylesheet_path
      Tailwindcss.tailwind_css_file_path
    end

    def view_component_ui_asset_tags
      stylesheet_link_tag(tailwind_stylesheet_path)
    end
  end
end
