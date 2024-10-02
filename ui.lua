local Ui = {}
Ui.__index = Ui

function Ui.new(inventory)
    local self = setmetatable({}, Ui)
    self.inventory = inventory
    self.hotbarTextures = {}
    self.selectedSlot = 1  

    for i, inventorySlot in ipairs(inventory) do
        if inventorySlot and inventorySlot.item and inventorySlot.item.texture then
            self.hotbarTextures[i] = inventorySlot.item  
        else
            self.hotbarTextures[i] = nil  
        end
    end

    return self
end

function Ui:selectItem(slot)
    if slot >= 1 and slot <= 5 then  
        self.selectedSlot = slot
    end
end

function Ui:draw(y)
    local hotbarHeight = 50  
    local numSlots = 5  
    local slotSize = 32  
    local slotSpacing = 4  
    local startX = 50  
    local adjustedY = y - 25  

    -- Draw the black rectangle background for the hotbar
    love.graphics.setColor(0, 0, 0, 1)  -- Set color to black
    love.graphics.rectangle("fill", startX - 2, adjustedY - 2, (slotSize + slotSpacing) * numSlots + slotSpacing, slotSize + 4)  
    love.graphics.setColor(1, 1, 1, 1)  -- Reset color to white

    for i = 1, numSlots do
        local item = self.hotbarTextures[i]
        local slotX = startX + (i - 1) * (slotSize + slotSpacing)  

        if i == self.selectedSlot then
            love.graphics.setColor(0.8, 0.8, 0, 1)  
            love.graphics.rectangle("line", slotX - 2, adjustedY - 2, slotSize + 4, slotSize + 4)  
            love.graphics.setColor(1, 1, 1, 1)  
        end

        if item and item.texture then
            local textureWidth = item.texture:getWidth()
            local textureHeight = item.texture:getHeight()

            local centeredX = slotX + (slotSize - textureWidth) / 2
            local centeredY = adjustedY + (slotSize - textureHeight) / 2

            love.graphics.draw(item.texture, centeredX, centeredY, 0, 1, 1)  
        else
            love.graphics.setColor(0.5, 0.5, 0.5, 1)  
            love.graphics.rectangle("fill", slotX, adjustedY, slotSize, slotSize)  
        end
    end

    love.graphics.setColor(1, 1, 1, 1)  
end


return Ui