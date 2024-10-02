local Player = {}
local Physics = require("physics")
local Textures = require("textures")

Player.x = 8000 / 2  
Player.y = -128
Player.width = 16
Player.height = 28
Player.speed = 100
Player.gravity = 250
Player.yVelocity = 0
Player.jumpHeight = -200
Player.grounded = false
Player.world = nil
Player.direction = "right"
Player.scaleX = 1
Player.flipSpeed = 10  
Player.inventory = {} 
Player.currentItemIndex = 1 
Player.projectiles = {}

Player.walkTimer = 0
Player.walkFrameDuration = 0.6

function Player.load(world)
    Player.world = world
end

function Player.update(dt, world)
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




    function love.mousepressed(x, y, button, istouch, presses)
        if button == 1 then  
            Player.useCurrentItem()
            Player.breakBlock(Player.world)
        end
    end
    

    Player.isWalking = horizontalVelocity ~= 0

    if Player.isWalking then
        Player.walkTimer = Player.walkTimer + dt
        if Player.walkTimer >= Player.walkFrameDuration then
            Player.walkTimer = 0  
        end
    else
        Player.walkTimer = 0  
    end

    if love.keyboard.isDown("space") and Player.grounded then
        Player.yVelocity = Player.jumpHeight
        Player.grounded = false
    end

    Physics.applyGravity(Player, dt, Player.world)

    Player.x = Player.x + horizontalVelocity * dt
    Player.y = Player.y + Player.yVelocity * dt

    Physics.checkGround(Player, Player.world)

    Player.updateDirectionScale(horizontalVelocity, dt)


    Player.updateCurrentItem(dt)



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
        currentItem.item:use(Player.direction, love.timer.getDelta())  
    end
end

function Player.updateDirectionScale(horizontalVelocity)
    if Player.direction == "left" then
        Player.scaleX = -1 -- Flip the sprite to the left
    elseif Player.direction == "right" then
        Player.scaleX = 1 -- Flip the sprite to the right
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
    print("Player Position: (" .. Player.x .. ", " .. Player.y .. ")")  -- Log the player's position
    print("Player Inventory:")
    for i, inventorySlot in ipairs(Player.inventory) do
        if inventorySlot and inventorySlot.item and inventorySlot.item.name then  
            print(inventorySlot.index .. ": " .. inventorySlot.item.name)  
        else
            print(inventorySlot.index .. ": [Empty Slot]")
        end
    end
end

function Player.breakBlock(world)
    local mouseX, mouseY = love.mouse.getPosition()
    local blockX = math.floor(mouseX / world.tileSize)
    local blockY = math.floor(mouseY / world.tileSize)

    -- Check if the calculated block coordinates are within the world bounds
    if blockX >= 1 and blockX <= world.worldWidth and blockY >= 1 and blockY <= world.worldHeight then
        local blockIndex = (blockY - 1) * world.worldWidth + blockX
        local block = world.tiles[blockIndex]
        local currentItem = Player.inventory[Player.currentItemIndex]  -- Get the currently selected item

        -- Log the block we are trying to mine
        if block then
            print("Attempting to mine block at (" .. blockX .. ", " .. blockY .. ") with tier: " .. block.tier)
        else
            print("No block found at (" .. blockX .. ", " .. blockY .. ")")
        end

        -- Check if the current item can break the block
        if block and currentItem and currentItem.tier > block.tier and currentItem.type >= 1 then
            world.tiles[blockIndex] = nil -- Remove the block
            print("Successfully mined block at (" .. blockX .. ", " .. blockY .. ") with item: " .. (currentItem.name or "unknown"))
        else
            if currentItem then
                print("Failed to mine block. Current item: " .. (currentItem.name or "unknown") .. 
                      ", Block tier: " .. (block and block.tier or "N/A") ..
                      ", Current item tier: " .. (currentItem.tier or "N/A") .. 
                      ", Item type: " .. (currentItem.type or "N/A"))
            else
                print("Failed to mine block. No current item selected.")
            end
        end
    else
        print("Block coordinates (" .. blockX .. ", " .. blockY .. ") are out of bounds.")
    end
end




function Player.draw()
    love.graphics.setColor(1, 1, 1)

    local texture

    local currentItem = Player.inventory[Player.currentItemIndex]
    local hasItemEquipped = currentItem and currentItem.item

    if Player.direction == "left" then
        if Player.isWalking then
            if Player.walkTimer < Player.walkFrameDuration / 3 then
                texture = hasItemEquipped and Textures.playerWalk1Item or Textures.playerWalk1
            elseif Player.walkTimer < 2 * Player.walkFrameDuration / 3 then
                texture = hasItemEquipped and Textures.playerWalk2Item or Textures.playerWalk2
            else
                texture = hasItemEquipped and Textures.playerWalk3Item or Textures.playerWalk3
            end
        else
            texture = hasItemEquipped and Textures.playerStilItem or Textures.playerStil
        end
    elseif Player.direction == "right" then
        if Player.isWalking then
            if Player.walkTimer < Player.walkFrameDuration / 3 then
                texture = hasItemEquipped and Textures.playerWalk1Item or Textures.playerWalk1
            elseif Player.walkTimer < 2 * Player.walkFrameDuration / 3 then
                texture = hasItemEquipped and Textures.playerWalk2Item or Textures.playerWalk2
            else
                texture = hasItemEquipped and Textures.playerWalk3Item or Textures.playerWalk3
            end
        else
            texture = hasItemEquipped and Textures.playerStilItem or Textures.playerStil
        end
    end

    love.graphics.draw(texture, Player.x, Player.y, 0, Player.scaleX, 1, Player.width / 2, Player.height / 2)

    if hasItemEquipped and currentItem.item.draw then
        local offsetX = (Player.direction == "left") and -10 or 10
        currentItem.item:draw(Player.x + offsetX, Player.y + 4, Player.direction, Player.scaleX)
    end
end

return Player