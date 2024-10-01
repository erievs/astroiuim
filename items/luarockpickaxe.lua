local Textures = require("textures")

local LuaRockPickaxe = {}
LuaRockPickaxe.__index = LuaRockPickaxe

function LuaRockPickaxe.new()
    local self = setmetatable({}, LuaRockPickaxe)
    self.name = "LuaRockPickaxe"
    self.rotation = 0
    self.active = true

    self.tier = 1
    self.damage = 5 + (self.tier - 1) * 3  

    self.swingState = "stopped"    
    self.swingAngle = 0            
    self.swingDuration = 0.5       
    self.cooldownDuration = 1.5    
    self.xScale = 1
    self.yScale = 1
    self.timer = 0                 
    self.swingSpeed = math.rad(60) / (self.swingDuration / 2)  
    self.maxSwingAngle = math.rad(30)  
    self.isCoolingDown = false     
    self.texture = Textures.luaRockPickaxe  
    return self
end

function LuaRockPickaxe:use(direction)  
    if self.isCoolingDown then
        return
    end

    if self.swingState == "stopped" then
        print("Swinged Pickaxe!")
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

function LuaRockPickaxe:update(dt)
    if self.isCoolingDown then
        self.timer = self.timer + dt
        if self.timer >= self.cooldownDuration then
            self.isCoolingDown = false  
        end
    elseif self.swingState ~= "stopped" then
        self.timer = self.timer + dt
    end
end

function LuaRockPickaxe:draw(playerX, playerY, direction)
    local texture = self.texture  

    if texture then
        local offsetX = (direction == "right") and 16 or -16
        local flipScaleX = (direction == "right") and 1 or -1

        love.graphics.draw(texture, playerX + offsetX, playerY, self.rotation, flipScaleX, 1, texture:getWidth() / 2, texture:getHeight() / 2)
    else
        print("Error: Texture for RustyKnife not found!")
    end
end

return LuaRockPickaxe