local Physics = {}

function Physics.applyGravity(player, dt)
    if not player.grounded then
        player.yVelocity = player.yVelocity + player.gravity * dt
    end
end

function Physics.checkGround(player, world)

    local belowX = math.floor(player.x / world.tileSize) + 1
    local belowY = math.floor((player.y + player.height) / world.tileSize) + 1

    if belowY <= world.mapHeight and belowY >= 1 and belowX <= world.mapWidth and belowX >= 1 then
        local block = world.tiles[belowX][belowY]

        if block then

            player.y = (belowY - 1) * world.tileSize - player.height  
            player.yVelocity = 0  
            player.grounded = true
        else

            player.grounded = false
        end
    else

        player.grounded = false
    end
end

return Physics