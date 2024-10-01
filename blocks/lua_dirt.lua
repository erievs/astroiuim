local Block = require("blocks.block")

local Dirt = {}
Dirt.__index = Dirt  -- Set the index of Dirt to itself for method lookups

-- Create a new Dirt block
function Dirt.new()
    local self = setmetatable({}, Dirt)  -- Create a new instance of Dirt
    self.image = love.graphics.newImage("assets/lua_dirt.png")  -- Load the image
    self.tier = 2  -- Set the tier
    self.hasHitbox = true  -- Set hasHitbox property
    self.width = 16  -- Set the width (optional)
    self.height = 16  -- Set the height (optional)
    return self  -- Return the new instance
end

-- Inherit the draw function from the Block class
function Dirt:draw(x, y)
    love.graphics.draw(self.image, x, y)
end

return Dirt
