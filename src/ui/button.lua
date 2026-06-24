local draw   = require "src.ui.utils.draw"
local theme  = require "src.ui.utils.theme"
local Button = {}
Button.__index = Button

function Button.new(x, y, w, h, label, onClick)
    return setmetatable({
        x = x, y = y, w = w, h = h,
        label = label,
        onClick = onClick,
        hovered = false,
    }, Button)
end

function Button:update(mx, my)
    self.hovered = mx >= self.x and mx <= self.x + self.w
                and my >= self.y and my <= self.y + self.h
end

function Button:draw(font)
    local glow = self.hovered and theme.alpha.btn_glow or theme.alpha.btn_glow_dim
    local fill = self.hovered and theme.color.btn_fill_hover or theme.color.btn_fill
    draw.glow_rect(self.x, self.y, self.w, self.h, theme.size.btn_corner, fill, theme.color.glow, glow * theme.alpha.btn_border)

    love.graphics.setFont(font)
    love.graphics.setColor(self.hovered and theme.color.text or theme.color.text_dim)
    local tw = font:getWidth(self.label)
    local th = font:getHeight()
    love.graphics.print(
        self.label,
        math.floor(self.x + (self.w - tw) / 2),
        math.floor(self.y + (self.h - th) / 2)
    )
end

function Button:mousepressed(mx, my, btn)
    if btn == 1 and self.hovered and self.onClick then
        self.onClick()
    end
end

return Button
