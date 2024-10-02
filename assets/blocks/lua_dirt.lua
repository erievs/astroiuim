local Block = require("blocks.block")

local Dirt = {}
Dirt.__index = Dirt  

function Dirt.new()
    local self = setmetatable({}, Dirt)  
    self.image = love.graphics.newImage("assets/lua_dirt.png")  
    self.tier = 2  
    self.hasHitbox = true  
    self.width = 16  
    self.height = 16  
    self.x = 0  
    self.y = 0  
    return self  
end

function Dirt:draw(x, y)
    self.x = x  
    self.y = y
    love.graphics.draw(self.image, self.x, self.y)
end

function Dirt:checkCollision(other)
    if not self.hasHitbox or not other.hasHitbox then
        return false
    end

    return self.x < other.x + other.width and
           self.x + self.width > other.x and
           self.y < other.y + other.height and
           self.y + self.height > other.y
end

function Dirt:highlight()
    love.graphics.setColor(1, 1, 0, 0.5) -- Yellow color for highlight
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(1, 1, 1, 1) -- Reset color
    -- Log block coordinates
    print("Stone Block Coordinates: X=" .. self.x .. ", Y=" .. self.y)
end

function Dirt:getTier()
    return self.tier
end

return Dirt
