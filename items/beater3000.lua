local Beater3000 = {}
Beater3000.__index = Beater3000

function Beater3000.new(texture)
    local self = setmetatable({}, Beater3000)
    self.texture = texture
    self.rotation = 0
    self.active = true
    self.damage = 10
    self.swingState = "stopped"  -- Track swing state
    self.swingAngle = 0           -- Current angle of the swing
    self.swingSpeed = 5           -- Speed of the swing
    self.maxSwingAngle = math.rad(30)  -- Maximum angle to swing (30 degrees)
    return self
end

function Beater3000:use(direction)
    if self.swingState == "stopped" then
        print("Swing Beater3000!")
        self.swingState = "forward"  -- Start the swing
    end

    -- Handle the swinging motion
    if self.swingState == "forward" then
        self.swingAngle = self.swingAngle + self.swingSpeed
        if self.swingAngle >= self.maxSwingAngle then
            self.swingAngle = self.maxSwingAngle
            self.swingState = "backward"  -- Change direction
        end
    elseif self.swingState == "backward" then
        self.swingAngle = self.swingAngle - self.swingSpeed
        if self.swingAngle <= 0 then
            self.swingAngle = 0
            self.swingState = "stopped"  -- Reset the swing
        end
    end

    -- Set the rotation based on the swing angle
    self.rotation = self.swingAngle * (direction == "right" and 1 or -1)  -- Rotate based on direction
end

function Beater3000:draw(playerX, playerY, direction, scaleX)
    local offsetX = (direction == "right") and 16 or -16  
    love.graphics.draw(self.texture, playerX + offsetX, playerY, self.rotation, scaleX, 1, self.texture:getWidth() / 2, self.texture:getHeight() / 2)
end

return Beater3000
