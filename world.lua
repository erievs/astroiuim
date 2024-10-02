local World = {}
local Textures = require("textures")
local Block = require("blocks.block")
local Dirt = require("blocks.lua_dirt") 
local Stone = require("blocks.lua_stone")  
local SimplexNoise = require("simplex")
local loveFilesystem = love.filesystem
local json = require("json")
local Player = require("player")

function World.load()
    World.tileSize = 16 
    World.chunkSize = 16
    World.tiles = {}
    World.chunks = {}
    World.loadQueue = {}
    World.startX = 0
    World.startY = 0

    -- Define fixed world boundaries
    World.worldWidth = 8000  -- Number of chunks wide
    World.worldHeight = 8000  -- Number of chunks tall

    -- Set parameters for terrain generation
    World.baseHeight = 10
    World.noiseScale = 0.3  -- Scale for terrain noise
    World.hillHeightScale = 10 -- Controls how tall the hills can be
    World.caveFrequency = 0.08  -- Frequency of caves
    World.caveDepth = 4  -- Maximum depth for caves

    print("Loading world...")
    World.generateInitialChunks(0, 0)
    print("Initial chunks generation started.")
end

function World.generateInitialChunks(startX, startY)
    for x = startX, startX + 1 do
        for y = startY, startY + 1 do
            World.generateTerrain(x, y)  -- Call to generate terrain for each chunk
        end
    end
end

function World.isChunkWithinBounds(chunkX, chunkY)
    return chunkX >= 0 and chunkX < World.worldWidth and chunkY >= 0 and chunkY < World.worldHeight
end

function World.generateTerrain(chunkX, chunkY)
    print(string.format("Generating terrain for chunk: (%d, %d)", chunkX, chunkY))

    local heightMap = {}  -- Store height information for the terrain

    for x = 1, World.chunkSize do
        local globalX = chunkX * World.chunkSize + x
        heightMap[x] = {}

        -- Generate base height using noise
        local baseNoise = SimplexNoise.Noise2D(globalX * World.noiseScale, 0)
        local baseHeight = World.baseHeight + baseNoise * World.hillHeightScale

        for tileY = 1, World.chunkSize do
            local globalY = chunkY * World.chunkSize + tileY
            local heightOffset = math.floor(math.abs(baseHeight + SimplexNoise.Noise2D(globalX * World.noiseScale, globalY * World.noiseScale) * World.hillHeightScale))

            -- Fill ground layers with dirt or stone based on height
            if tileY <= heightOffset then
                if tileY <= heightOffset - 2 then
                    World.tiles[(globalX - 1) * World.chunkSize + tileY] = Stone.new()  -- Use stone deeper in the ground
                else
                    World.tiles[(globalX - 1) * World.chunkSize + tileY] = Dirt.new()
                end
                heightMap[x][tileY] = heightOffset
            else
                heightMap[x][tileY] = nil
            end
        end
    end

    -- Generate caves
    World.generateCaves(chunkX, chunkY, heightMap)

    -- Ensure solid ground
    World.ensureSolidGround(chunkX, heightMap)

    print(string.format("Finished generating terrain for chunk: (%d, %d)", chunkX, chunkY))
end

function World.ensureSolidGround(chunkX, heightMap)
    for x = 1, World.chunkSize do
        local globalX = chunkX * World.chunkSize + x
        local lastHeight = 0

        for tileY = 1, World.chunkSize do
            local height = heightMap[x][tileY] or lastHeight

            -- If height is nil, fill the gap with dirt until we reach the lastHeight
            if height == nil and lastHeight > 0 then
                World.tiles[(globalX - 1) * World.chunkSize + tileY] = Dirt.new()  -- Fill the gap with dirt
            else
                lastHeight = height
            end
        end
    end
end

function World.generateCaves(chunkX, chunkY, heightMap)
    for x = 1, World.chunkSize do
        local globalX = chunkX * World.chunkSize + x

        for y = 1, World.chunkSize do
            local globalY = chunkY * World.chunkSize + y

            -- Only proceed if there's a height value for this x coordinate
            local heightAtX = heightMap[x] and heightMap[x][1] or nil

            if heightAtX and globalY <= heightAtX then  -- Check if height exists and is not nil
                local caveNoise = SimplexNoise.Noise2D(globalX * World.noiseScale * 2, globalY * World.noiseScale * 2)

                if caveNoise < World.caveFrequency then
                    local caveDepth = World.caveDepth + math.random(0, 2)  -- Randomize cave depth
                    for caveY = globalY, math.max(globalY - caveDepth, 1), -1 do
                        if caveY > 0 then  -- Ensure it doesn't go below ground level
                            World.tiles[(globalX - 1) * World.chunkSize + caveY] = nil  -- Remove block to create cave
                        end
                    end
                end
            end
        end
    end
end

function World.save(filename)
    local worldData = {
        tiles = {},
    }

    for index, block in pairs(World.tiles) do
        if block and block.type then
            worldData.tiles[index] = {type = block.type}
        end
    end

    local success, jsonData = pcall(json.encode, worldData)
    if not success then
        print("Error encoding JSON: " .. tostring(jsonData))
    else
        love.filesystem.write(filename, jsonData)
        print("World saved successfully to: " .. filename)
    end
end

function World.isColliding(x, y)
    local gridX = math.floor(x / World.tileSize) + 1
    local gridY = math.floor(y / World.tileSize) + 1

    if gridX >= 1 and gridX <= World.chunkSize * World.worldWidth and gridY >= 1 and gridY <= World.chunkSize * World.worldHeight then
        return World.tiles[gridX * World.chunkSize + gridY] and World.tiles[gridX * World.chunkSize + gridY].hasHitbox
    end
    return false
end

function World.draw()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local startX = math.max(1, math.floor(Player.x / World.tileSize) - (screenWidth / World.tileSize) / 2)
    local startY = math.max(1, math.floor(Player.y / World.tileSize) - (screenHeight / World.tileSize) / 2)

    local chunkStartX = math.floor(startX / World.chunkSize)
    local chunkStartY = math.floor(startY / World.chunkSize)
    local chunkEndX = math.ceil((startX + screenWidth / World.tileSize) / World.chunkSize)
    local chunkEndY = math.ceil((startY + screenHeight / World.tileSize) / World.chunkSize)

    for chunkX = chunkStartX, chunkEndX do
        for chunkY = chunkStartY, chunkEndY do
            World.loadChunk(chunkX, chunkY)
        end
    end

    for chunkX = chunkStartX, chunkEndX do
        for chunkY = chunkStartY, chunkEndY do
            for x = chunkX * World.chunkSize, math.min(World.chunkSize * World.worldWidth, (chunkX + 1) * World.chunkSize) do
                for y = chunkY * World.chunkSize, math.min(World.chunkSize * World.worldHeight, (chunkY + 1) * World.chunkSize) do
                    local block = World.tiles[x * World.chunkSize + y]
                    if block then
                        block:draw((x - 1) * World.tileSize, (y - 1) * World.tileSize)
                    end
                end
            end
        end
    end
end

function World.loadChunk(chunkX, chunkY)
    if World.isChunkWithinBounds(chunkX, chunkY) and not World.chunks[chunkX .. "," .. chunkY] then
        World.generateTerrain(chunkX, chunkY)
        World.chunks[chunkX .. "," .. chunkY] = true
    end
end

return World
