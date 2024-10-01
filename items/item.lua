-- items/item.lua
local Item = {}
Item.__index = Item

function Item.new(name, texture, damage, itemType)
    local self = setmetatable({}, Item)
    self.name = name
    self.texture = texture
    self.damage = damage
    self.type = itemType
    self.rotation = 0
    self.active = true  

    return self
end

function Item:rotate(direction)
    if direction == "left" then
        self.rotation = self.rotation - math.rad(5)  
    elseif direction == "right" then
        self.rotation = self.rotation + math.rad(5)  
    end
end

return Item
