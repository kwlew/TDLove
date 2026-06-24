local T = {}

-- ── Font paths ─────────────────────────────────────────────────────────────────
T.font = {
    afacad_bold      = "assets/fonts/Afacad-Flux/AfacadFlux-Bold.ttf",
    afacad_extrabold = "assets/fonts/Afacad-Flux/AfacadFlux-ExtraBold.ttf",
    afacad_regular   = "assets/fonts/Afacad-Flux/AfacadFlux-Regular.ttf",
    fira_semibold    = "assets/fonts/Fira-Sans/FiraSans-SemiBold.ttf",
}

-- ── Color palettes ─────────────────────────────────────────────────────────────
-- 3-component {r,g,b} → passed to draw.glow_* functions
-- 4-component {r,g,b,a} → passed to love.graphics.setColor
T.palettes = {}

T.palettes.blue = {
    bg             = {0.10, 0.10, 0.15},

    glow           = {0.35, 0.80, 1.00},
    glow_title     = {0.40, 0.80, 1.00},
    glow_panel     = {0.30, 0.70, 1.00},
    glow_hud       = {0.30, 0.75, 1.00},

    text           = {1.00, 1.00, 1.00, 1.00},
    text_dim       = {1.00, 1.00, 1.00, 0.85},
    text_hint      = {1.00, 1.00, 1.00, 0.25},
    text_muted     = {1.00, 1.00, 1.00, 0.22},
    text_faint     = {1.00, 1.00, 1.00, 0.12},
    text_label     = {1.00, 1.00, 1.00, 0.82},
    text_title     = {1.00, 1.00, 1.00, 0.92},
    text_subtitle  = {0.55, 0.75, 1.00, 0.45},
    text_section   = {0.45, 0.65, 1.00, 0.55},
    text_pct       = {0.65, 0.82, 1.00, 0.60},
    text_gold      = {0.90, 0.80, 0.20, 0.85},
    text_lives     = {0.30, 0.90, 0.40, 0.85},
    github_dim     = {1.00, 1.00, 1.00, 0.55},

    btn_fill         = {0.05, 0.15, 0.55, 0.08},
    btn_fill_hover   = {0.10, 0.35, 0.90, 0.18},
    hud_fill         = {0.06, 0.12, 0.22, 0.65},
    panel_fill       = {0.06, 0.09, 0.16, 0.80},
    title_box_fill   = {0.20, 0.50, 1.00, 0.07},
    section_divider  = {0.30, 0.50, 1.00, 0.12},

    toggle_on         = {0.22, 0.68, 0.38, 0.90},
    toggle_off        = {0.20, 0.24, 0.32, 0.90},
    toggle_border_on  = {0.25, 0.82, 0.48, 0.65},
    toggle_border_off = {0.30, 0.35, 0.38, 0.28},
    toggle_glow_outer = {0.22, 0.80, 0.45, 0.12},
    toggle_glow_inner = {0.22, 0.80, 0.45, 0.35},
    toggle_knob       = {1.00, 1.00, 1.00, 0.95},

    slider_track        = {0.15, 0.20, 0.35, 0.70},
    slider_track_border = {0.30, 0.60, 1.00, 0.22},
    slider_fill_glow    = {0.30, 0.70, 1.00, 0.18},
    slider_fill         = {0.30, 0.65, 1.00, 0.90},
}

T.palettes.red = {
    bg             = {0.12, 0.08, 0.10},

    glow           = {1.00, 0.22, 0.18},
    glow_title     = {1.00, 0.30, 0.12},
    glow_panel     = {0.85, 0.15, 0.15},
    glow_hud       = {1.00, 0.20, 0.10},

    text           = {1.00, 1.00, 1.00, 1.00},
    text_dim       = {1.00, 1.00, 1.00, 0.85},
    text_hint      = {1.00, 1.00, 1.00, 0.25},
    text_muted     = {1.00, 1.00, 1.00, 0.22},
    text_faint     = {1.00, 1.00, 1.00, 0.12},
    text_label     = {1.00, 1.00, 1.00, 0.82},
    text_title     = {1.00, 1.00, 1.00, 0.92},
    text_subtitle  = {1.00, 0.60, 0.55, 0.45},
    text_section   = {1.00, 0.55, 0.45, 0.55},
    text_pct       = {1.00, 0.65, 0.55, 0.60},
    text_gold      = {0.90, 0.80, 0.20, 0.85},
    text_lives     = {0.30, 0.90, 0.40, 0.85},
    github_dim     = {1.00, 1.00, 1.00, 0.55},

    btn_fill         = {0.40, 0.05, 0.05, 0.08},
    btn_fill_hover   = {0.75, 0.12, 0.10, 0.18},
    hud_fill         = {0.18, 0.06, 0.06, 0.65},
    panel_fill       = {0.14, 0.05, 0.06, 0.80},
    title_box_fill   = {0.80, 0.15, 0.10, 0.07},
    section_divider  = {0.80, 0.18, 0.12, 0.12},

    toggle_on         = {0.72, 0.15, 0.12, 0.90},
    toggle_off        = {0.24, 0.10, 0.10, 0.90},
    toggle_border_on  = {0.90, 0.20, 0.15, 0.65},
    toggle_border_off = {0.38, 0.14, 0.14, 0.28},
    toggle_glow_outer = {0.80, 0.18, 0.12, 0.12},
    toggle_glow_inner = {0.80, 0.18, 0.12, 0.35},
    toggle_knob       = {1.00, 1.00, 1.00, 0.95},

    slider_track        = {0.22, 0.08, 0.08, 0.70},
    slider_track_border = {0.80, 0.18, 0.12, 0.22},
    slider_fill_glow    = {1.00, 0.22, 0.12, 0.18},
    slider_fill         = {1.00, 0.25, 0.15, 0.90},
}

-- ── Active palette ─────────────────────────────────────────────────────────────
T.color = T.palettes.blue

function T.activate(name)
    T.color = T.palettes[name] or T.palettes.blue
end

-- ── Alpha values ───────────────────────────────────────────────────────────────
-- Standalone alphas passed as the `alpha` arg to draw.glow_* functions.
T.alpha = {
    btn_glow      = 1.00,   -- hovered button glow strength
    btn_glow_dim  = 0.55,   -- unhovered button glow strength
    btn_border    = 0.90,   -- button border alpha at full glow
    title_box     = 0.65,
    panel         = 0.60,
    hud_line      = 0.65,
    slider_handle = 0.90,
}

-- ── Sizes ──────────────────────────────────────────────────────────────────────
T.size = {
    -- Font sizes
    font_btn              = 22,
    font_menu_title       = 56,
    font_hint             = 14,
    font_settings_title   = 38,
    font_settings_section = 14,
    font_settings_label   = 18,
    font_settings_hint    = 13,

    -- Main menu button layout
    btn_w            = 240,
    btn_h            = 54,
    btn_gap          = 16,
    btn_corner       = 6,
    menu_btn_start_y = 0.52,   -- fraction of screen height
    menu_title_y     = 0.22,   -- fraction of screen height

    -- Main menu title box
    title_pad_x  = 28,
    title_pad_y  = 14,
    title_corner = 12,
    subtitle_gap = 6,

    -- GitHub icon (main menu)
    github_size   = 32,
    github_margin = 14,

    -- Settings back button
    back_btn_w      = 140,
    back_btn_h      = 44,
    back_btn_margin = 16,

    -- Settings panel layout
    panel_w = 560,
    row_h   = 44,
    sec_h   = 38,
    title_h = 54,
    pad_h   = 36,
    pad_v   = 20,

    -- Toggle widget
    toggle_w           = 48,
    toggle_h           = 24,
    toggle_knob_inset  = 3,    -- knob radius = toggle_h/2 - inset
    toggle_glow_outer  = 3,    -- outer glow ring offset (px)
    toggle_glow_inner  = 1,    -- inner glow ring offset (px)

    -- Select widget
    select_w       = 140,
    select_arrow_w = 24,

    -- Slider widget
    slider_w           = 200,
    slider_h           = 6,
    slider_corner      = 3,
    slider_glow_expand = 2,    -- fill-glow vertical overshoot (px)
    handle_r           = 8,

    -- HUD bar
    hud_h       = 58,
    hud_item_y  = 16,
    hud_wave_x  = 20,
    hud_gold_x  = 160,
    hud_lives_x = 320,

    -- Shared hint text position
    hint_margin_x      = 10,
    hint_margin_bottom = 24,

    -- In-game placeholder text
    placeholder_y_offset = 11,
}

return T
