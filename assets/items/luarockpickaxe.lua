local Textures = require("textures")
local Item = require("items.item")  -- Ensure the Item module is required

local LuaRockPickaxe = {}
LuaRockPickaxe.__index = LuaRockPickaxe

function LuaRockPickaxe.new()
    local self = setmetatable({}, LuaRockPickaxe)
    
    local itemType = Item.Types.TOOL 
    self.name = "LuaRockPickaxe"
    self.rotation = 0
    self.active = true
    self.tier = 1
    self.damage = 5 + (self.tier - 1) * 3  
    self.type = itemType
    self.swingState = "stopped"    
    self.swingAngle = 0            
    self.swingDuration = 0.5       
    self.cooldownDuration = 1.5    
    self.xScale = 0.75
    self.yScale = 0.75
    self.timer = 0                 
    self.swingSpeed = math.rad(60) / (self.swingDuration / 2)  
    self.maxSwingAngle = math.rad(30)  
    self.isCoolingDown = false     
    self.texture = Textures.luaRockPickaxe  
    
    return self
end

function LuaRockPickaxe:use(playerDirection)  
    if self.isCoolingDown then
        return
    end

    if self.swingState == "stopped" then
        print("Swinged Pickaxe!")
        self.swingState = "forward"  
        self.timer = 0               
        self.direction = playerDirection  -- Set direction based on player action
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

    -- Update rotation based on the swing angle and player direction
    self.rotation = self.swingAngle * (self.direction == "right" and 1 or -1)
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

function LuaRockPickaxe:draw(playerX, playerY)
    local texture = self.texture  

    if texture then
        local offsetX = (self.direction == "right") and 16 or -16
        local flipScaleX = (self.direction == "right") and 1 or -1

        love.graphics.draw(texture, playerX + offsetX, playerY, self.rotation, flipScaleX, 1, texture:getWidth() / 2, texture:getHeight() / 2)
    else
        print("Error: Texture for LuaRockPickaxe not found!")
    end
end

return LuaRockPickaxe
