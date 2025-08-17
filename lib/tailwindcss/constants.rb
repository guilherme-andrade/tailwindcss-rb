# frozen_string_literal: true

module Tailwindcss
  module Constants
    COLOR_WEIGHTS = ([nil] + %i[50 100 200 300 400 500 600 700 800 900]).freeze
    BREAKPOINTS = %i[xs sm md lg xl 2xl].freeze
    PSEUDO_SELECTORS = %i[hover focus active visited disabled first last first_of_type last_of_type odd even
      group_hover].freeze
    PSEUDO_ELEMENTS = %i[before after file first_letter first_line selection backdrop marker].freeze

    ALIGN_CONTENT = %i[normal center start end between around evenly baseline stretch].freeze
    ALIGN_ITEMS = %i[start end center baseline stretch].freeze
    BACKFACE_VISIBILITY = %i[visible hidden].freeze
    BACKGROUND_ATTACHMENT = %i[fixed local scroll].freeze
    BACKGROUND_BLEND_MODE = %i[normal multiply screen overlay darken lighten color-dodge color-burn hard-light
      soft-light difference exclusion hue saturation color luminosity].freeze
    BACKGROUND_CLIP = %i[border padding content].freeze
    BACKGROUND_IMAGE = %i[none gradient-to-t gradient-to-tr gradient-to-r gradient-to-br gradient-to-b gradient-to-bl
      gradient-to-l gradient-to-tl].freeze
    BACKGROUND_ORIGIN = %i[border padding content].freeze
    BACKGROUND_POSITION = %i[bottom center left left-bottom left-top right right-bottom right-top
      top].freeze
    BACKGROUND_REPEAT = %i[repeat repeat-x repeat-y no-repeat round space].freeze
    BORDER_RADIUSES = %i[none sm md lg full].freeze
    BACKGROUND_SIZE = %i[auto cover contain].freeze
    BORDER_COLLAPSE = %i[collapse separate].freeze
    BORDER_RADIUS = %i[none sm true md lg xl 2xl 3xl full] + [true].freeze
    CONTENT = %i[none].freeze
    SPACING = %i[0 px 0.5 1 1.5 2 2.5 3 3.5 4 5 6 7 8 9 10 11 12 14 16 20 24 28 32 36 40 44 48 52 56 60 64 72
      80 96 auto].freeze
    BORDER_STYLE = %i[solid dashed dotted double none].freeze
    BORDER = [true, false].freeze
    BORDER_WIDTH = %i[0 1 2 4 8].freeze
    BOX_DECORATION_BREAK = %i[slice clone].freeze
    BOX_SHADOW = (%i[sm md lg xl 2xl inner none] + [true]).freeze
    BOX_SIZING = %i[border content].freeze
    CAPTION_SIDE = %i[top bottom].freeze
    CLEAR = %i[left right both none].freeze
    COLORS = %i[transparent current inherit black white neutral zync stone gray red amber yellow lime green blue indigo
      violet purple pink slate emerald fuchsia rose cyan teal sky].freeze
    COLOR_SCHEME = {
      primary: :purple,
      secondary: :indigo,
      success: :emerald,
      danger: :rose,
      warning: :yellow,
      info: :teal,
      neutral: :gray,
      dark: :black,
      light: :white
    }.freeze
    COLUMNS = %i[auto 1 2 3 4 5 6 7 8 9 10 11 12 3xs 2xs xs sm md lg xl 2xl 3xl 4xl 5xl 6xl 7xl].freeze
    COLUMN_SPAN = %i[auto 1 2 3 4 5 6 7 8 9 10 11 12 all].freeze
    COLUMN_START = %i[auto 1 2 3 4 5 6 7 8 9 10 11 12 13].freeze
    COLUMN_END = %i[auto 1 2 3 4 5 6 7 8 9 10 11 12 13].freeze
    CURSOR = %i[auto default pointer wait text move help not-allowed].freeze
    DISPLAY = %i[block inline-block inline inline-table table table-caption table-cell table-column table-column-group
      table-footer-group table-header-group table-row table-row-group flow-root grid inline-grid contents
      list-item hidden flex inline-flex].freeze
    EMPTY_CELLS = %i[show hide].freeze
    FLEX_BASIS = %i[auto 0].freeze
    FLEX_DIRECTION = %i[row row-reverse col col-reverse].freeze
    FLEX_GROW = [0, true].freeze
    FLEX_SHRINK = [0, true].freeze
    FLEX_WRAP = %i[wrap nowrap wrap-reverse].freeze
    FLEX = %i[1 auto initial none].freeze
    FONT_FAMILY = %i[sans serif mono].freeze
    FONT_SIZE = %i[xs sm base lg xl 2xl 3xl 4xl 5xl 6xl 7xl 8xl 9xl].freeze
    FONT_STYLE = %i[italic non-italic].freeze
    FONT_VARIANT_NUMERIC = %i[normal-nums ordinal slashed-zero lining-nums oldstyle-nums proportional-nums
      tabular-nums diagonal-fractions stacked-fractions].freeze
    FONT_WEIGHT = %i[hairline thin light normal medium semibold bold extrabold black].freeze
    GRID_AUTO_COLUMNS = %i[auto min max fr].freeze
    GRID_AUTO_FLOW = %i[row column dense row-dense column-dense].freeze
    GRID_AUTO_ROWS = %i[auto min max fr].freeze
    GRID_TEMPLATE_COLUMNS = %i[none 1 2 3 4 5 6 7 8 9 10 11 12].freeze
    GRID_TEMPLATE_ROWS = %i[none 1 2 3 4 5 6].freeze
    GROUP = [true, false].freeze
    SIZES = %i[0 px 0.5 1 1.5 2 2.5 3 3.5 4 5 6 7 8 9 10 11 12 14 16 20 24 28 32 36 40 44 48 52 56 60 64 72
      80 96 auto 1/2 1/3 2/3 1/4 2/4 3/4 1/5 2/5 3/5 4/5 1/6 2/6 3/6 4/6 5/6 full screen min max fit].freeze
    HYPHENS = %i[none manual auto].freeze
    ISOLATION = %i[isolate auto].freeze
    JUSTIFY_CONTENT = %i[start end center between around evenly].freeze
    JUSTIFY_ITEMS = %i[start end center baseline stretch].freeze
    JUSTIFY_SELF = %i[start end center auto stretch].freeze
    LETTER_SPACING = %i[tighter tight normal wide wider widest].freeze
    LINE_HEIGHT = %i[none tight snug normal relaxed loose 3 4 5 6 7 8 9 10].freeze
    LIST_STYLE_IMAGE = %i[none].freeze
    LIST_STYLE_POSITION = %i[inside outside].freeze
    LIST_STYLE_TYPE = %i[none disc decimal].freeze
    MAX_SIZE = %i[0 xs sm md lg xl 2xl 3xl 4xl 5xl 6xl 7xl full screen min max fit prose screen-sm screen-md
      screen-lg screen-xl screen-2xl].freeze
    MIN_SIZE = [0, :full, :min, :max, :fit].freeze
    MIX_BLEND_MODE = %i[normal multiply screen overlay darken lighten color-dodge color-burn hard-light soft-light
      difference exclusion hue saturation color luminosity].freeze
    OBJECT_FIT = %i[contain cover fill none scale-down].freeze
    OBJECT_POSITION = %i[top right bottom left center].freeze
    OPACITY = %i[0 5 10 20 25 30 40 50 60 70 75 80 90 95 100].freeze
    ORDER = %i[first last none 1 2 3 4 5 6 7 8 9 10 11 12].freeze
    OUTLINE_STYLE = %i[dotted dashed solid double none].freeze
    OUTLINE_WIDTH = %i[0 1 2 4 8].freeze
    OVERFLOW = %i[auto hidden visible scroll x-hidden y-hidden x-scroll y-scroll x-auto y-auto].freeze
    PLACE_ITEMS = %i[start end center stretch].freeze
    PLACE_SELF = %i[start end center stretch].freeze
    POINTER_EVENTS = %i[none auto].freeze
    POSITION = %i[static fixed absolute relative sticky].freeze
    RESIZE = %i[true false none x y].freeze
    ROTATE = %i[0 1 2 3 6 12 45 90 180].map { [_1, :"-#{_1}"] }.flatten.freeze
    ROW_SPAN = %i[auto 1 2 3 4 5 6 full].freeze
    ROW_START = %i[auto 1 2 3 4 5 6 7].freeze
    ROW_END = %i[auto 1 2 3 4 5 6 7].freeze
    SCALE = %i[0 50 75 90 95 100 105 110 125 150 200].freeze
    SCROLL_BEHAVIOR = %i[auto smooth].freeze
    SCROLL_SNAP_ALIGN = %i[start end center none].freeze
    SCROLL_SNAP_STOP = %i[always normal].freeze
    SCROLL_SNAP_TYPE = %i[none mandatory proximity].freeze
    TABLE_LAYOUT = %i[auto fixed].freeze
    TEXT_ALIGN = %i[left center right justify start end].freeze
    TEXT_DECORATION = %i[underline line-through no-underline].freeze
    TEXT_DECORATION_STYLE = %i[solid double dotted dashed wavy].freeze
    TEXT_DECORATION_THICKNESS = %i[auto from-font 0 1 2 4 8].freeze
    TEXT_OVERFLOW = %i[ellipsis truncate].freeze
    TEXT_TRANSFORM = %i[uppercase lowercase capitalize normal].freeze
    TEXT_UNDERLINE_OFFSET = %i[auto 0 1 2 4 8].freeze
    TRANSFORM_ORIGIN = %i[center top-right top top-left right bottom-right bottom bottom-left left].freeze
    TRANSITION = %i[none all colors opacity shadow transform].freeze
    TRANSLATE = %i[0 0.5 px 1 1.5 2 2.5 3 3.5 4 5 6 7 8 9 10 11 12 14 16 20 24 28 32 36 40 44 48 52 56 60 64 72 80 96
      1/2 1/3 2/3 1/4 2/3 2/4 3/4 full].map do
      [_1, :"-#{_1}"]
    end.flatten.freeze
    USER_SELECT = %i[none text all auto].freeze
    VERTICAL_ALIGN = %i[top middle bottom baseline text-top text-bottom sub super].freeze
    VISIBILITY = %i[visible invisible collapse].freeze
    WHITESPACE = %i[normal nowrap pre pre-line pre-wrap break-words].freeze
    WILL_CHANGE = %i[auto scroll contents opacity transform].freeze
    WORD_BREAK = %i[normal words all keep].freeze
    Z_INDEX = %i[0 10 20 30 40 50 auto].freeze

    COLOR_WITH_WEIGHTS = proc {
      COLORS.map do |color|
        COLOR_WEIGHTS.map { |weight| [color, weight].compact.join("-") }
      end.flatten.freeze
    }

    THEME = {
      align_content: {values: ALIGN_CONTENT, token: "content"},
      align_items: {values: ALIGN_ITEMS, token: "items", alias: :items},
      backface_visibility: {values: BACKFACE_VISIBILITY, token: "backface"},
      background: {values: COLOR_WITH_WEIGHTS, token: "bg", alias: :bg},
      background_attachment: {values: BACKGROUND_ATTACHMENT, token: "bg"},
      background_blend_mode: {values: BACKGROUND_BLEND_MODE, token: "bg"},
      background_clip: {values: BACKGROUND_CLIP, token: "bg"},
      background_color: {values: COLOR_WITH_WEIGHTS, token: "bg"},
      background_image: {values: BACKGROUND_IMAGE, token: "bg"},
      background_origin: {values: BACKGROUND_ORIGIN, token: "bg"},
      background_position: {values: BACKGROUND_POSITION, token: "bg"},
      background_repeat: {values: BACKGROUND_REPEAT, token: "bg"},
      background_size: {values: BACKGROUND_SIZE, token: "bg"},
      border_bottom_left_radius: {values: BORDER_RADIUS, token: "rounded-bl"},
      border_bottom_right_radius: {values: BORDER_RADIUS, token: "rounded-br"},
      border_top_left_radius: {values: BORDER_RADIUS, token: "rounded-tl"},
      border_top_right_radius: {values: BORDER_RADIUS, token: "rounded-tr"},
      border_top_radius: {values: BORDER_RADIUS, token: "rounded-t"},
      border_bottom_radius: {values: BORDER_RADIUS, token: "rounded-b"},
      border_left_radius: {values: BORDER_RADIUS, token: "rounded-l"},
      border_right_radius: {values: BORDER_RADIUS, token: "rounded-r"},
      border_collapse: {values: BORDER_COLLAPSE, token: "border"},
      border_color: {values: COLOR_WITH_WEIGHTS, token: "border"},
      border_radius: {values: BORDER_RADIUS, token: "rounded", alias: :rounded},
      border_spacing: {values: SPACING, token: "border-spacing"},
      border_spacing_x: {values: SPACING, token: "border-spacing-x"},
      border_spacing_y: {values: SPACING, token: "border-spacing-y"},
      border_style: {values: BORDER_STYLE, token: "border"},
      border: {values: BORDER, token: "border"},
      border_top: {values: BORDER + BORDER_WIDTH, token: "border-t"},
      border_bottom: {values: BORDER + BORDER_WIDTH, token: "border-b"},
      border_left: {values: BORDER + BORDER_WIDTH, token: "border-l"},
      border_right: {values: BORDER + BORDER_WIDTH, token: "border-r"},
      border_width: {values: BORDER_WIDTH, token: "border"},
      border_y: {values: BORDER_WIDTH, token: "border-y"},
      border_x: {values: BORDER_WIDTH, token: "border-x"},
      border_start: {values: BORDER_WIDTH, token: "border-s"},
      border_end: {values: BORDER_WIDTH, token: "border-e"},
      bottom: {values: SIZES, token: "bottom"},
      box_decoration_break: {values: BOX_DECORATION_BREAK, token: "box-decoration-break"},
      box_shadow: {values: BOX_SHADOW, token: "shadow", alias: :shadow},
      box_sizing: {values: BOX_SIZING, token: "box"},
      caption_side: {values: CAPTION_SIDE, token: "caption"},
      clear: {values: CLEAR, token: "clear"},
      color: {values: COLOR_WITH_WEIGHTS, token: "text", alias: :text},
      column_gap: {values: SPACING, token: "gap"},
      column_span: {values: COLUMN_SPAN, token: "col-span", alias: :col_span},
      column_start: {values: COLUMN_START, token: "col-start", alias: :col_start},
      column_end: {values: COLUMN_END, token: "col-end", alias: :col_end},
      columns: {values: COLUMNS, token: "columns"},
      content: {values: CONTENT, token: "content"},
      cursor: {values: CURSOR, token: "cursor"},
      display: {values: DISPLAY, token: nil, alias: :d},
      empty_cells: {values: EMPTY_CELLS, token: "empty"},
      end: {values: SIZES, token: "end"},
      fill: {values: COLOR_WITH_WEIGHTS, token: "fill"},
      flex_basis: {values: FLEX_BASIS, token: "flex"},
      flex_direction: {values: FLEX_DIRECTION, token: "flex", alias: :direction},
      flex_grow: {values: FLEX_GROW, token: "flex", alias: :grow},
      flex_shrink: {values: FLEX_SHRINK, token: "flex", alias: :shrink},
      flex_wrap: {values: FLEX_WRAP, token: "flex"},
      flex: {values: FLEX, token: "flex"},
      font_family: {values: FONT_FAMILY, token: "font"},
      font_size: {values: FONT_SIZE, token: "text"},
      font_style: {values: FONT_STYLE, token: nil},
      font_variant_numeric: {values: FONT_VARIANT_NUMERIC, token: nil},
      font_weight: {values: FONT_WEIGHT, token: "font"},
      grid_auto_columns: {values: GRID_AUTO_COLUMNS, token: "auto-cols"},
      grid_auto_flow: {values: GRID_AUTO_FLOW, token: "grid-flow"},
      grid_auto_rows: {values: GRID_AUTO_ROWS, token: "auto-rows"},
      group: {values: GROUP, token: "group"},
      gap: {values: SPACING, token: "gap"},
      gap_x: {values: SPACING, token: "gap-x"},
      gap_y: {values: SPACING, token: "gap-y"},
      grid_template_columns: {values: GRID_TEMPLATE_COLUMNS, token: "grid-cols", alias: :grid_cols},
      grid_template_rows: {values: GRID_TEMPLATE_ROWS, token: "grid-rows"},
      height: {values: SIZES, token: "h", alias: :h},
      hyphens: {values: HYPHENS, token: "hyphens"},
      inset: {values: SIZES, token: "inset"},
      inset_x: {values: SIZES, token: "inset-x"},
      inset_y: {values: SIZES, token: "inset-y"},
      isolation: {values: ISOLATION, token: "isolation"},
      justify_content: {values: JUSTIFY_CONTENT, token: "justify", alias: :justify},
      justify_items: {values: JUSTIFY_ITEMS, token: "justify"},
      justify_self: {values: JUSTIFY_SELF, token: "justify"},
      left: {values: SIZES, token: "left"},
      letter_spacing: {values: LETTER_SPACING, token: "tracking"},
      line_height: {values: LINE_HEIGHT, token: "leading"},
      list_style_image: {values: LIST_STYLE_IMAGE, token: "list-image"},
      list_style_position: {values: LIST_STYLE_POSITION, token: "list"},
      list_style_type: {values: LIST_STYLE_TYPE, token: "list"},
      margin_bottom: {values: SPACING, token: "mb", alias: :mb},
      margin_end: {values: SPACING, token: "me", alias: :me},
      margin_left: {values: SPACING, token: "ml", alias: :ml},
      margin_right: {values: SPACING, token: "mr", alias: :mr},
      margin_start: {values: SPACING, token: "ms", alias: :ms},
      margin_top: {values: SPACING, token: "mt", alias: :mt},
      margin_x: {values: SPACING, token: "mx", alias: :mx},
      margin_y: {values: SPACING, token: "my", alias: :my},
      margin: {values: SPACING, token: "m", alias: :m},
      max_height: {values: SIZES, token: "max-h", alias: :max_h},
      max_width: {values: SIZES, token: "max-w", alias: :max_w},
      min_height: {values: SIZES, token: "min-h", alias: :min_h},
      min_width: {values: SIZES, token: "min-w", alias: :min_w},
      mix_blend_mode: {values: MIX_BLEND_MODE, token: "mix-blend"},
      object_fit: {values: OBJECT_FIT, token: "object"},
      object_position: {values: OBJECT_POSITION, token: "object"},
      opacity: {values: OPACITY, token: "opacity"},
      order: {values: ORDER, token: "order"},
      outline_color: {values: COLOR_WITH_WEIGHTS, token: "outline"},
      outline_style: {values: OUTLINE_STYLE, token: "outline", alias: :outline},
      outline_width: {values: OUTLINE_WIDTH, token: "outline"},
      overflow: {values: OVERFLOW, token: "overflow"},
      overflow_x: {values: OVERFLOW, token: "overflow-x"},
      overflow_y: {values: OVERFLOW, token: "overflow-y"},
      padding: {values: SPACING, token: "p", alias: :p},
      padding_bottom: {values: SPACING, token: "pb", alias: :pb},
      padding_left: {values: SPACING, token: "pl", alias: :pl},
      padding_right: {values: SPACING, token: "pr", alias: :pr},
      padding_top: {values: SPACING, token: "pt", alias: :pt},
      padding_x: {values: SPACING, token: "px", alias: :px},
      padding_y: {values: SPACING, token: "py", alias: :py},
      place_items: {values: PLACE_ITEMS, token: "place"},
      place_self: {values: PLACE_SELF, token: "place"},
      pointer_events: {values: POINTER_EVENTS, token: "pointer"},
      position: {values: POSITION, token: nil},
      resize: {values: RESIZE, token: "resize"},
      right: {values: SIZES, token: "right"},
      rotate: {values: ROTATE, token: proc {
        _1.to_s.start_with?("-") ? "-rotate-#{_1.to_s[1..]}" : "rotate-#{_1}"
      }},
      row_gap: {values: SPACING, token: "gap"},
      row_span: {values: ROW_SPAN, token: "row-span"},
      row_start: {values: ROW_START, token: "row-start"},
      row_end: {values: ROW_END, token: "row-end"},
      scale: {values: SCALE, token: "scale"},
      scale_x: {values: SCALE, token: "scale-x"},
      scale_y: {values: SCALE, token: "scale-y"},
      scroll_behavior: {values: SCROLL_BEHAVIOR, token: "scroll"},
      scroll_margin_bottom: {values: SPACING, token: "scroll-mb"},
      scroll_margin_left: {values: SPACING, token: "scroll-ml"},
      scroll_margin_right: {values: SPACING, token: "scroll-mr"},
      scroll_margin_top: {values: SPACING, token: "scroll-mt"},
      scroll_margin_x: {values: SPACING, token: "scroll-mx"},
      scroll_margin_y: {values: SPACING, token: "scroll-my"},
      scroll_margin_start: {values: SPACING, token: "scroll-ms"},
      scroll_margin_end: {values: SPACING, token: "scroll-me"},
      scroll_padding_bottom: {values: SPACING, token: "scroll-pb"},
      scroll_padding_left: {values: SPACING, token: "scroll-pl"},
      scroll_padding_right: {values: SPACING, token: "scroll-pr"},
      scroll_padding_top: {values: SPACING, token: "scroll-pt"},
      scroll_padding_x: {values: SPACING, token: "scroll-px"},
      scroll_padding_y: {values: SPACING, token: "scroll-py"},
      scroll_padding_start: {values: SPACING, token: "scroll-ps"},
      scroll_padding_end: {values: SPACING, token: "scroll-pe"},
      scroll_snap_align: {values: SCROLL_SNAP_ALIGN, token: "snap"},
      scroll_snap_stop: {values: SCROLL_SNAP_STOP, token: "snap"},
      scroll_snap_type: {values: SCROLL_SNAP_TYPE, token: "snap"},
      start: {values: SIZES, token: "start"},
      table_layout: {values: TABLE_LAYOUT, token: "table"},
      text_align: {values: TEXT_ALIGN, token: "text"},
      text_decoration_color: {values: COLOR_WITH_WEIGHTS, token: "decoration"},
      text_decoration_style: {values: TEXT_DECORATION_STYLE, token: "decoration"},
      text_decoration_thickness: {values: TEXT_DECORATION_THICKNESS, token: "decoration"},
      text_decoration: {values: TEXT_DECORATION, token: proc { _1 }},
      text_indent: {values: SPACING, token: "indent"},
      text_overflow: {values: TEXT_OVERFLOW, token: proc { |v| (v == "truncate") ? "truncate" : "text-#{v}" }},
      text_transform: {values: TEXT_TRANSFORM, token: nil},
      text_underline_offset: {values: TEXT_UNDERLINE_OFFSET, token: "underline-offset"},
      top: {values: SIZES, token: "top"},
      transform_origin: {values: TRANSFORM_ORIGIN, token: "origin"},
      transition: {values: TRANSITION + [true], token: "transition"},
      translate_x: {values: TRANSLATE, token: proc {
        _1.to_s.start_with?("-") ? "-translate-#{_1.to_s[1..]}" : "translate-#{_1}"
      }},
      translate_y: {values: TRANSLATE, token: proc {
        _1.to_s.start_with?("-") ? "-translate-y-#{_1.to_s[1..]}" : "translate-y-#{_1}"
      }},
      user_select: {values: USER_SELECT, token: "select"},
      vertical_align: {values: VERTICAL_ALIGN, token: "align"},
      visibility: {values: VISIBILITY, token: nil},
      whitespace: {values: WHITESPACE, token: "whitespace", alias: :white_space},
      width: {values: SIZES, token: "w", alias: :w},
      will_change: {values: WILL_CHANGE, token: "will-change"},
      word_break: {values: WORD_BREAK, token: "break"},
      z_index: {values: Z_INDEX, token: "z", alias: :z}
    }.freeze
  end
end
