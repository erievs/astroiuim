local UI = {}
UI.font = love.graphics.newFont(14)  

function UI.load()

end

function UI.draw(x, y)
    love.graphics.setFont(UI.font)  
    love.graphics.setColor(1, 1, 1, 1)  

    local text = string.format("X: %.1f, Y: %.1f", x, y)

    local textWidth = UI.font:getWidth(text)
    local textHeight = UI.font:getHeight(text)

    love.graphics.print(text, love.graphics.getWidth() - textWidth - 10, 10)
end

return UI