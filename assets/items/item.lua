local Item = {}
Item.__index = Item

Item.Types = {
    TOOL = "tool",
    WEAPON = "weapon",
    ARMOR = "armor",
    CONSUMABLE = "consumable",

}

function Item.new(name, texture, damage, tier)
    local self = setmetatable({}, Item)

    local itemType = Item.Types.WEAPON  
    if name:find("Pickaxe") then
        itemType = Item.Types.TOOL
    elseif name:find("Knife") then
        itemType = Item.Types.WEAPON
    end

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