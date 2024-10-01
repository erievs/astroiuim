local Player = {}
local Physics = require("physics")
local Textures = require("textures")

Player.x = 5000 / 2  
Player.y = -32
Player.width = 16
Player.height = 42
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

    if love.keyboard.isDown("a") then
        horizontalVelocity = -Player.speed
        if Player.direction ~= "left" then
            Player.direction = "left"  
        end
    elseif love.keyboard.isDown("d") then
        horizontalVelocity = Player.speed
        if Player.direction ~= "right" then
            Player.direction = "right"  
        end
    end

    if love.keyboard.isDown("space") and Player.grounded then
        Player.yVelocity = Player.jumpHeight
        Player.grounded = false
    end

    -- Mouse press handling moved outside of update
    function love.mousepressed(x, y, button)
        if button == 1 then  -- Left mouse button (use the current item)
            Player.useCurrentItem()
        end
    end

    Player.updateCurrentItem(dt)

    Physics.applyGravity(Player, dt)

    Player.x = Player.x + horizontalVelocity * dt
    Player.y = Player.y + Player.yVelocity * dt

    Physics.checkGround(Player, Player.world)

    -- Pass dt to the direction update function
    Player.updateDirectionScale(horizontalVelocity, dt)
end

function Player.updateCurrentItem(dt)
    local currentItem = Player.inventory[Player.currentItemIndex]
    if currentItem and currentItem.item and currentItem.item.update then
        currentItem.item:update(dt) 
    end
end

function Player.useCurrentItem()
    local currentItem = Player.inventory[Player.currentItemIndex]
    if currentItem and currentItem.item and currentItem.item.use then
        currentItem.item:use(Player.direction, love.timer.getDelta())  -- Pass dt to use method
    end
end

function Player.updateDirectionScale(horizontalVelocity, dt)
    if Player.direction == "left" then
        Player.scaleX = Player.scaleX - Player.flipSpeed * dt
        if Player.scaleX < -1 then Player.scaleX = -1 end  
    elseif Player.direction == "right" then
        Player.scaleX = Player.scaleX + Player.flipSpeed * dt
        if Player.scaleX > 1 then Player.scaleX = 1 end  
    end
end

function Player.addItem(item, slot)
    if slot > 0 and slot <= 10 then
        local inventorySlot = {
            index = slot,  
            item = item                       
        }
        Player.inventory[slot] = inventorySlot  
        print(item.name .. " added to inventory at slot " .. slot)  
    else
        print("Error: Invalid inventory slot.")
    end
end

function Player.logInventory()
    print("Player Inventory:")
    for i, inventorySlot in ipairs(Player.inventory) do
        if inventorySlot and inventorySlot.item and inventorySlot.item.name then  
            print(inventorySlot.index .. ": " .. inventorySlot.item.name)  
        else
            print(inventorySlot.index .. ": [Empty Slot]")
        end
    end
end

function Player.draw()
    
    love.graphics.setColor(1, 1, 1)  
    love.graphics.draw(Textures.playerRight, Player.x, Player.y, 0, Player.scaleX, 1, Player.width / 2, Player.height / 2)

    local offsetX = (Player.direction == "left") and -14 or 14

    local currentItem = Player.inventory[Player.currentItemIndex]

    if currentItem and currentItem.item and currentItem.item.draw then
        currentItem.item:draw(Player.x + offsetX, Player.y + 10, Player.direction, Player.scaleX)
    else
        print("Warning: Current item is nil or does not have a draw method.")
    end

end

return Player
