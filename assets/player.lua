local Player = {}
local Physics = require("physics")
local Textures = require("textures")

Player.x = 8000 / 2  
Player.y = -196
Player.width = 1
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

    Physics.move(Player, dt)

    Physics.handleInput(Player)


    Physics.applyGravity(Player, dt, Player.world)

    Player.x = Player.x + horizontalVelocity * dt
    Player.y = Player.y + Player.yVelocity * dt

    Physics.checkGround(Player, Player.world)


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
    print("Player Position: (" .. Player.x .. ", " .. Player.y .. ")")  
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

    print("Mouse Position: (" .. mouseX .. ", " .. mouseY .. ")")

    if blockX >= 1 and blockX <= world.worldWidth and blockY >= 1 and blockY <= world.worldHeight then
        local blockIndex = (blockY - 1) * world.worldWidth + blockX
        local block = world.tiles[blockIndex]

        print("Current Item Index: " .. Player.currentItemIndex)
        print("Inventory Size: " .. #Player.inventory)

        -- List block under the mouse
        if block then
            local blockTier = block:getTier()  -- Attempt to retrieve the block's tier using the getTier method
            if blockTier == nil then
                print("Block at (" .. blockX .. ", " .. blockY .. ") has no valid tier.")
            else
                print("Attempting to mine block at (" .. blockX .. ", " .. blockY .. ") with block tier: " .. blockTier)
            end
        else
            print("No block found at (" .. blockX .. ", " .. blockY .. ")")
        end

        -- List all blocks around the mouse cursor
        print("Listing blocks around (" .. blockX .. ", " .. blockY .. "):")
        for dy = -1, 1 do
            for dx = -1, 1 do
                local nearbyBlockX = blockX + dx
                local nearbyBlockY = blockY + dy
                if nearbyBlockX >= 1 and nearbyBlockX <= world.worldWidth and nearbyBlockY >= 1 and nearbyBlockY <= world.worldHeight then
                    local nearbyBlockIndex = (nearbyBlockY - 1) * world.worldWidth + nearbyBlockX
                    local nearbyBlock = world.tiles[nearbyBlockIndex]
                    if nearbyBlock then
                        print("Nearby block at (" .. nearbyBlockX .. ", " .. nearbyBlockY .. ") with tier: " .. (nearbyBlock:getTier() or "N/A"))
                    else
                        print("No block at (" .. nearbyBlockX .. ", " .. nearbyBlockY .. ")")
                    end
                end
            end
        end

        local currentItem = Player.inventory[Player.currentItemIndex]

        if currentItem then
            if currentItem.item then
                local itemName = currentItem.item.name or "unknown"
                local currentItemTier = currentItem.item.tier or 0  
                local currentItemType = currentItem.item.type or "N/A"

                print("Current item details - Name: " .. itemName .. ", Tier: " .. currentItemTier .. ", Type: " .. currentItemType)

                if block and currentItemTier > (blockTier or 0) and (currentItemType == "tool" or currentItemType == "weapon") then
                    world.tiles[blockIndex] = nil  -- Remove the block from the world
                    print("Successfully mined block at (" .. blockX .. ", " .. blockY .. ") with item: " .. itemName)
                else
                    print("Failed to mine block. Current item: " .. itemName .. 
                          ", Block tier: " .. (blockTier or "N/A") ..
                          ", Current item tier: " .. currentItemTier .. 
                          ", Item type: " .. currentItemType)
                end
            else
                print("Failed to mine block. Current item is not valid. Current item has no 'item' property.")
            end
        else
            print("Failed to mine block. Current item is not valid. No item at current index.")
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
                texture = hasItemEquipped and Textures.playerWalk1ItemLeft or Textures.playerWalk1Left
            elseif Player.walkTimer < 2 * Player.walkFrameDuration / 3 then
                texture = hasItemEquipped and Textures.playerWalk2ItemLeft or Textures.playerWalk2Left
            else
                texture = hasItemEquipped and Textures.playerWalk3ItemLeft or Textures.playerWalk3Left
            end
        else
            texture = hasItemEquipped and Textures.playerStilItemLeft or Textures.playerStilLeft
        end
    elseif Player.direction == "right" then
        if Player.isWalking then
            if Player.walkTimer < Player.walkFrameDuration / 3 then
                texture = hasItemEquipped and Textures.playerWalk1ItemRight or Textures.playerWalk1Right
            elseif Player.walkTimer < 2 * Player.walkFrameDuration / 3 then
                texture = hasItemEquipped and Textures.playerWalk2ItemRight or Textures.playerWalk2Right
            else
                texture = hasItemEquipped and Textures.playerWalk3ItemRight or Textures.playerWalk3Right
            end
        else
            texture = hasItemEquipped and Textures.playerStilItemRight or Textures.playerStilRight
        end
    end

    if texture then
        love.graphics.draw(texture, Player.x, Player.y, 0, Player.scaleX, 1, Player.width / 2, Player.height / 2)
    else
        print("Warning: No texture available for Player.draw")
    end

    if hasItemEquipped and currentItem.item.draw then
        local offsetX = (Player.direction == "left") and 24 or 10
        currentItem.item:draw(Player.x + offsetX, Player.y + 4, Player.direction, Player.scaleX)
    end
end

return Player