local Item = {}
Item.__index = Item

function Item.new(name, texture, damage, itemType, tier)
    local self = setmetatable({}, Item)
    self.name = name
    self.texture = texture
    self.damage = damage
    self.type = itemType
    self.tier = tier or 0 
    self.rotation = 0
    self.active = true  

    return self
end

return Item
