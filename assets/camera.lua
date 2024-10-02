local Camera = {}
Camera.__index = Camera

function Camera.new()
    local self = setmetatable({}, Camera)
    self.x = 0
    self.y = 0
    return self
end

function Camera:update(player)
    -- Center the camera on the player
    self.x = player.x - love.graphics.getWidth() / 2 + player.width / 2
    self.y = player.y - love.graphics.getHeight() / 2 + player.height / 2
end

function Camera:apply()
    love.graphics.translate(-self.x, -self.y)
end

return Camera
