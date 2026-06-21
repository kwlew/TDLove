local rgb_text = {}

local function hsv2rgb(h, s, v)
    local i = math.floor(h * 6) % 6
    local f = h * 6 - math.floor(h * 6)
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    if i == 0 then return v, t, p
    elseif i == 1 then return q, v, p
    elseif i == 2 then return p, v, t
    elseif i == 3 then return p, q, v
    elseif i == 4 then return t, p, v
    else                return v, p, q end
end

-- Draw rainbow text using the currently set font.
-- speed:  hue cycles per second  (default 0.2)
-- spread: hue offset per letter  (default 0.08)
function rgb_text.draw(text, x, y, speed, spread)
    speed  = speed  or 0.2
    spread = spread or 0.08
    local font = love.graphics.getFont()
    local t    = love.timer.getTime()
    local cx   = x
    for i = 1, #text do
        local ch  = text:sub(i, i)
        local hue = (t * speed + i * spread) % 1
        love.graphics.setColor(hsv2rgb(hue, 1, 1))
        love.graphics.print(ch, cx, y)
        cx = cx + font:getWidth(ch)
    end
end

return rgb_text
