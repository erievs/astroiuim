local Player = {}
local Physics = require("physics")
local Textures = require("textures")

Player.x = 5000 / 2  
Player.y = -32
Player.width = 16
Player.height = 22
Player.speed = 200
Player.gravity = 400
Player.yVelocity = 0
Player.jumpHeight = -300
Player.grounded = false
Player.world = nil
Player.direction = "right"
Player.scaleX = 1  
Player.flipSpeed = 10  
Player.inventory = {} 
Player.currentItemIndex = 1 
Player.projectiles = {} 

function Player.load(world)
    Player.world = world
end

function Player.update(dt)
    local horizontalVelocity = 0

    if love.keyboard.isDown("left") then
        horizontalVelocity = -Player.speed
        if Player.direction ~= "left" then
            Player.direction = "left"  
        end
    elseif love.keyboard.isDown("right") then
        horizontalVelocity = Player.speed
        if Player.direction ~= "right" then
            Player.direction = "right"  
        end
    end
    


    if love.keyboard.isDown("space") and Player.grounded then
        Player.yVelocity = Player.jumpHeight
        Player.grounded = false
    end

    if love.mouse.isDown(1) then  -- Left mouse button
        local currentItem = Player.inventory[Player.currentItemIndex]
        if currentItem and currentItem.use then
            currentItem:use(Player.direction)  -- Use the sword
        end
    end
    
    Physics.applyGravity(Player, dt)

    Player.x = Player.x + horizontalVelocity * dt
    Player.y = Player.y + Player.yVelocity * dt

    Physics.checkGround(Player, Player.world)

    if Player.direction == "left" then
        Player.scaleX = Player.scaleX - Player.flipSpeed * dt
        if Player.scaleX < -1 then Player.scaleX = -1 end  
    elseif Player.direction == "right" then
        Player.scaleX = Player.scaleX + Player.flipSpeed * dt
        if Player.scaleX > 1 then Player.scaleX = 1 end  
    end

end

function Player.draw()
    love.graphics.setColor(1, 1, 1)  
    love.graphics.draw(Textures.playerRight, Player.x, Player.y, 0, Player.scaleX, 1, Player.width / 2, Player.height / 2)


    local currentItem = Player.inventory[Player.currentItemIndex]
    if currentItem then
        love.graphics.draw(currentItem.texture, Player.x, Player.y + 10, currentItem.rotation, 1, 1, currentItem.texture:getWidth() / 2, currentItem.texture:getHeight() / 2)
    end

end

return Player