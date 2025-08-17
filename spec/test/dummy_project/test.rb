# frozen_string_literal: true

Tailwindcss::Style.new(
  bg: :red,
  color: color_scheme_token(:primary, 100),
  border_color: color_scheme_token(:secondary),
  text_decoration_color: color_token(:red),
  flex: true,
  _hover: { bg: :blue, _sm: { mt: 10 }, _after: { p: 10, _lg: { p: 14 } } },
  _before: { content: '[""]' },
  _lg: { mt: 10 }
)
