local M = {}

-- Draws a filled rectangle with a multi-pass glowing border.
-- fill:  {r,g,b,a} table, or nil to skip the fill.
-- color: {r,g,b} table for the glow and border.
-- alpha: alpha of the sharp main border; glow passes scale from it.
function M.glow_rect(x, y, w, h, radius, fill, color, alpha)
    if fill then
        love.graphics.setColor(fill[1], fill[2], fill[3], fill[4])
        love.graphics.rectangle("fill", x, y, w, h, radius)
    end
    local r, g, b = color[1], color[2], color[3]
    love.graphics.setColor(r, g, b, alpha * 0.08)
    love.graphics.rectangle("line", x - 4, y - 4, w + 8, h + 8, radius + 4)
    love.graphics.setColor(r, g, b, alpha * 0.16)
    love.graphics.rectangle("line", x - 2, y - 2, w + 4, h + 4, radius + 2)
    love.graphics.setColor(r, g, b, alpha * 0.30)
    love.graphics.rectangle("line", x - 1, y - 1, w + 2, h + 2, radius + 1)
    love.graphics.setLineWidth(1.5)
    love.graphics.setColor(r, g, b, alpha)
    love.graphics.rectangle("line", x, y, w, h, radius)
    love.graphics.setLineWidth(1)
end

-- Draws a horizontal line with a downward glow bloom.
-- color: {r,g,b} table. alpha: alpha of the main line.
function M.glow_hline(x1, x2, y, color, alpha)
    local r, g, b = color[1], color[2], color[3]
    love.graphics.setColor(r, g, b, alpha * 0.12)
    love.graphics.line(x1, y + 4, x2, y + 4)
    love.graphics.setColor(r, g, b, alpha * 0.28)
    love.graphics.line(x1, y + 2, x2, y + 2)
    love.graphics.setLineWidth(1.5)
    love.graphics.setColor(r, g, b, alpha)
    love.graphics.line(x1, y, x2, y)
    love.graphics.setLineWidth(1)
end

-- Draws a circle with soft glow blooms and a glowing ring border.
-- fill:  {r,g,b,a} table for the solid circle, or nil to skip.
-- color: {r,g,b} table for the glow and ring.
-- alpha: alpha of the sharp ring border; glow blooms scale from it.
function M.glow_circle(cx, cy, r, fill, color, alpha)
    local cr, cg, cb = color[1], color[2], color[3]
    love.graphics.setColor(cr, cg, cb, alpha * 0.17)
    love.graphics.circle("fill", cx, cy, r + 5)
    love.graphics.setColor(cr, cg, cb, alpha * 0.31)
    love.graphics.circle("fill", cx, cy, r + 2)
    if fill then
        love.graphics.setColor(fill[1], fill[2], fill[3], fill[4])
        love.graphics.circle("fill", cx, cy, r)
    end
    love.graphics.setLineWidth(1.5)
    love.graphics.setColor(cr, cg, cb, alpha)
    love.graphics.circle("line", cx, cy, r)
    love.graphics.setLineWidth(1)
end

return M
