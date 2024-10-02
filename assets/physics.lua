local Physics = {}

function Physics.applyGravity(player, dt)
    if not player.grounded then
        player.yVelocity = player.yVelocity + player.gravity * dt
    end

    player.y = player.y + player.yVelocity * dt
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
            player.y = (belowY - 1) * world.tileSize - player.height
            player.yVelocity = 0 
            player.grounded = true
            print("Player landed on block at: ", block.x, block.y)
        else
            player.grounded = false
        end
    else
        player.grounded = false
    end
end

function Physics.move(player, dt)
    local horizontalVelocity = Physics.handleInput(player)

    -- Move horizontally and check for collisions
    if horizontalVelocity ~= 0 then
        local newX = player.x + horizontalVelocity
        if not Physics.checkWallCollision(player, player.world, newX, player.y) then
            player.x = newX
        else
            -- Resolve collision with wall
            Physics.handleCollisionResponse(player, horizontalVelocity)
        end
    end

    -- Apply gravity after horizontal movement
    Physics.applyGravity(player, dt)
end

function Physics.handleInput(player)
    local horizontalVelocity = 0

    if love.keyboard.isDown("a") then
        horizontalVelocity = -player.speed
        player.direction = "left"
    elseif love.keyboard.isDown("d") then
        horizontalVelocity = player.speed
        player.direction = "right"
    end

    -- Handle jumping
    if love.keyboard.isDown("space") and player.grounded then
        player.yVelocity = -player.jumpHeight  -- Negative value to jump up
        player.grounded = false
        print("Player jumped")
    end

    return horizontalVelocity
end

function Physics.checkWallCollision(player, world, newX, newY)
    local leftIndex = math.floor(newX / world.tileSize) + 1
    local rightIndex = math.floor((newX + player.width) / world.tileSize) + 1
    local topIndex = math.floor(newY / world.tileSize) + 1
    local bottomIndex = math.floor((newY + player.height) / world.tileSize) + 1

    for i = -1, 1 do
        -- Check left side
        if leftIndex + i >= 1 and leftIndex + i <= world.worldWidth * world.chunkSize then
            local leftBlockTop = world.tiles[(leftIndex + i - 1) * world.chunkSize + topIndex]
            local leftBlockBottom = world.tiles[(leftIndex + i - 1) * world.chunkSize + bottomIndex]

            -- Ensure the block exists before checking properties
            if leftBlockTop and leftBlockTop.hasHitbox then
                print("Collision with wall on the left at block: ", leftBlockTop.x, leftBlockTop.y)
                return true
            end

            if leftBlockBottom and leftBlockBottom.hasHitbox then
                print("Collision with wall on the left at block: ", leftBlockBottom.x, leftBlockBottom.y)
                return true
            end
        end

        -- Check right side
        if rightIndex + i >= 1 and rightIndex + i <= world.worldWidth * world.chunkSize then
            local rightBlockTop = world.tiles[(rightIndex + i - 1) * world.chunkSize + topIndex]
            local rightBlockBottom = world.tiles[(rightIndex + i - 1) * world.chunkSize + bottomIndex]

            -- Ensure the block exists before checking properties
            if rightBlockTop and rightBlockTop.hasHitbox then
                print("Collision with wall on the right at block: ", rightBlockTop.x, rightBlockTop.y)
                return true
            end

            if rightBlockBottom and rightBlockBottom.hasHitbox then
                print("Collision with wall on the right at block: ", rightBlockBottom.x, rightBlockBottom.y)
                return true
            end
        end
    end

    return false 
end


function Physics.handleCollisionResponse(player, horizontalVelocity)
    local direction = horizontalVelocity > 0 and "right" or "left"
    local indexOffset = direction == "right" and -1 or 0
    local blockIndex = math.floor((player.x + (direction == "right" and player.width or 0)) / player.world.tileSize) + 1

    if blockIndex >= 1 and blockIndex <= player.world.worldWidth * player.world.chunkSize then
        local topIndex = math.floor(player.y / player.world.tileSize) + 1
        local bottomIndex = math.floor((player.y + player.height) / player.world.tileSize) + 1
        
        for i = -1, 1 do
            local block = player.world.tiles[(blockIndex + indexOffset + i - 1) * player.world.chunkSize + topIndex]
            if block and block.hasHitbox then
                if direction == "right" then
                    player.x = (blockIndex + indexOffset) * player.world.tileSize - player.width  -- Push player out to the left
                    print("Collision resolved: Player pushed left")
                else
                    player.x = blockIndex * player.world.tileSize  -- Push player out to the right
                    print("Collision resolved: Player pushed right")
                end
                break
            end
        end
    end
end

-- Additional function to check intersection and resolve accordingly
function Physics.checkIntersection(player, block)
    local playerRect = {
        x = player.x,
        y = player.y,
        width = player.width,
        height = player.height,
    }

    local blockRect = {
        x = block.x,
        y = block.y,
        width = block.width,
        height = block.height,
    }

    -- Check for intersection
    if (playerRect.x < blockRect.x + blockRect.width and
        playerRect.x + playerRect.width > blockRect.x and
        playerRect.y < blockRect.y + blockRect.height and
        playerRect.y + playerRect.height > blockRect.y) then
        print("Intersection detected between player and block at: ", blockRect.x, blockRect.y)
        return true
    end
    return false
end

-- Function to resolve collision
function Physics.resolveCollision(player, block)
    if Physics.checkIntersection(player, block) then
        -- Determine the direction of collision and adjust player's position
        local playerBottom = player.y + player.height
        local playerRight = player.x + player.width
        local blockBottom = block.y + block.height
        local blockRight = block.x + block.width

        local overlapLeft = playerRight - block.x
        local overlapRight = blockRight - player.x
        local overlapTop = playerBottom - block.y
        local overlapBottom = blockBottom - player.y

        local minOverlap = math.min(overlapLeft, overlapRight, overlapTop, overlapBottom)

        if minOverlap == overlapLeft then
            player.x = player.x - minOverlap  -- Move player left
            print("Resolved collision: Player moved left")
        elseif minOverlap == overlapRight then
            player.x = player.x + minOverlap  -- Move player right
            print("Resolved collision: Player moved right")
        elseif minOverlap == overlapTop then
            player.y = player.y - minOverlap  -- Move player up
            print("Resolved collision: Player moved up")
        elseif minOverlap == overlapBottom then
            player.y = player.y + minOverlap  -- Move player down
            print("Resolved collision: Player moved down")
        end
    end
end

return Physics
