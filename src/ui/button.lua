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
    if self.hovered then
        love.graphics.setColor(0.30, 0.60, 1.00, 0.90)
    else
        love.graphics.setColor(0.12, 0.30, 0.65, 0.70)
    end
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, 6)

    love.graphics.setColor(0.40, 0.70, 1.00, self.hovered and 0.80 or 0.40)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h, 6)

    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1, self.hovered and 1 or 0.85)
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
