local Physics = {}

function Physics.applyGravity(player, dt)
    -- Apply gravity only if the player is not grounded
    if not player.grounded then
        player.yVelocity = player.yVelocity + player.gravity * dt
    end

    -- Update the player's vertical position based on current velocity
    player.y = player.y + player.yVelocity * dt

    -- Check for ground collision after updating the vertical position
    Physics.checkGround(player, player.world)
end

function Physics.checkGround(player, world)
    local belowX = math.floor(player.x / world.tileSize) + 1
    local belowY = math.floor((player.y + player.height) / world.tileSize) + 1

    if belowY <= world.worldHeight * world.chunkSize and belowY >= 1 and 
       belowX <= world.worldWidth * world.chunkSize and belowX >= 1 then
        local index = (belowX - 1) * world.chunkSize + belowY
        local block = world.tiles[index]

        if block and block.hasHitbox then
            -- Snap the player to the top of the block
            player.y = (belowY - 1) * world.tileSize - player.height
            player.yVelocity = 0 -- Reset vertical velocity when landing
            player.grounded = true
        else
            player.grounded = false
        end
    else
        player.grounded = false
    end
end

function Physics.move(player, dt)
    if player.grounded then
        -- Only allow horizontal movement if the player is grounded
        Physics.checkCollisions(player, dt)
    else
        -- Stop horizontal movement when in the air
        player.xVelocity = 0
    end
end

function Physics.checkCollisions(player, dt)
    local horizontalVelocity = 0

    if love.keyboard.isDown("a") then
        horizontalVelocity = -player.speed * dt
        player.direction = "left"
    elseif love.keyboard.isDown("d") then
        horizontalVelocity = player.speed * dt
        player.direction = "right"
    end

    local newX = player.x + horizontalVelocity

    -- Check for wall collisions
    if not Physics.checkWallCollision(player, player.world, newX, player.y) then
        player.x = newX
    else
        -- Handle collision response (stop movement, adjust position, etc.)
        Physics.handleCollisionResponse(player, newX)
    end
end

function Physics.checkWallCollision(player, world, newX, y)
    local leftIndex = math.floor(newX / world.tileSize) + 1
    local rightIndex = math.floor((newX + player.width) / world.tileSize) + 1
    local topIndex = math.floor(y / world.tileSize) + 1
    local bottomIndex = math.floor((y + player.height) / world.tileSize) + 1

    -- Check for collisions on the left and right sides
    for i = -1, 1 do
        if leftIndex + i >= 1 and leftIndex + i <= world.worldWidth * world.chunkSize then
            local leftBlock = world.tiles[(leftIndex + i - 1) * world.chunkSize + topIndex]
            if leftBlock and leftBlock.hasHitbox then
                return true -- Collision detected on the left side
            end

            local leftBottomBlock = world.tiles[(leftIndex + i - 1) * world.chunkSize + bottomIndex]
            if leftBottomBlock and leftBottomBlock.hasHitbox then
                return true -- Collision detected on the left bottom corner
            end
        end

        if rightIndex + i >= 1 and rightIndex + i <= world.worldWidth * world.chunkSize then
            local rightBlock = world.tiles[(rightIndex + i - 1) * world.chunkSize + topIndex]
            if rightBlock and rightBlock.hasHitbox then
                return true -- Collision detected on the right side
            end

            local rightBottomBlock = world.tiles[(rightIndex + i - 1) * world.chunkSize + bottomIndex]
            if rightBottomBlock and rightBottomBlock.hasHitbox then
                return true -- Collision detected on the right bottom corner
            end
        end
    end

    return false -- No collision detected
end

function Physics.handleCollisionResponse(player, newX)
    local blockIndex = math.floor(newX / player.world.tileSize) + 1
    local block = player.world.tiles[(blockIndex - 1) * player.world.chunkSize + math.floor(player.y / player.world.tileSize) + 1]
    
    if block and block.hasHitbox then
        if player.direction == "right" then
            player.x = (blockIndex - 1) * player.world.tileSize - player.width -- Stop at the left edge of the block
        else
            player.x = blockIndex * player.world.tileSize -- Stop at the right edge of the block
        end
    end
end

return Physics
