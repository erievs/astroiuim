local Textures = require("textures")

local RustyKnife = {}
RustyKnife.__index = RustyKnife

function RustyKnife.new()
    local self = setmetatable({}, RustyKnife)
    self.name = "Rusty Knife"  
    self.rotation = 0
    self.active = true
    self.damage = 10
    self.swingState = "stopped"    
    self.swingAngle = 0            
    self.tier = 0
    self.xScale = 1  
    self.yScale = 1  
    self.swingDuration = 0.5       
    self.cooldownDuration = 2.5    
    self.timer = 0                 
    self.swingSpeed = math.rad(60) / (self.swingDuration / 2)  
    self.maxSwingAngle = math.rad(30)  
    self.isCoolingDown = false     
    self.texture = Textures.rightRustyKnifeTexture 
    return self
end

function RustyKnife:use(direction)  
    if self.isCoolingDown then
        return
    end

    if self.swingState == "stopped" then
        print("Swinged RustyKnife!")
        self.swingState = "forward"  
        self.timer = 0               
    end

    if self.swingState == "forward" then
        self.swingAngle = self.swingAngle + self.swingSpeed
        if self.swingAngle >= self.maxSwingAngle then
            self.swingAngle = self.maxSwingAngle
            self.swingState = "backward"  
        end
    elseif self.swingState == "backward" then
        self.swingAngle = self.swingAngle - self.swingSpeed
        if self.swingAngle <= 0 then
            self.swingAngle = 0
            self.swingState = "stopped"  
            self.isCoolingDown = true    
            self.timer = 0               
        end
    end

    self.rotation = self.swingAngle * (direction == "right" and 1 or -1)
end

function RustyKnife:update(dt)
    if self.isCoolingDown then
        self.timer = self.timer + dt
        if self.timer >= self.cooldownDuration then
            self.isCoolingDown = false  
        end
    elseif self.swingState ~= "stopped" then
        self.timer = self.timer + dt
    end
end

function RustyKnife:draw(playerX, playerY, direction)
    local texture = self.texture  

    if texture then
        local offsetX = (direction == "right") and 16 or -16
        local flipScaleX = (direction == "right") and 1 or -1

        love.graphics.draw(texture, playerX + offsetX, playerY, self.rotation, flipScaleX, 1, texture:getWidth() / 2, texture:getHeight() / 2)
    else
        print("Error: Texture for RustyKnife not found!")
    end
end

return RustyKnife
