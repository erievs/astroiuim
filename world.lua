local World = {}
local Textures = require("textures")
local Block = require("blocks.block")
local Dirt = require("blocks.lua_dirt")
local SimplexNoise = require("simplex")
local loveFilesystem = love.filesystem
local json = require("json")  
local Player = require("player")  

function World.load()
    World.tileSize = 16 
    World.mapWidth = 5000  / World.tileSize  
    World.mapHeight = 1000 / World.tileSize  
    World.tiles = {}

    World.generateTerrain()
end

function World.generateTerrain()
    local noiseScale = 0.05  
    local maxHeight = World.mapHeight * 0.5  

    for x = 1, World.mapWidth do
        World.tiles[x] = {}
        local noiseValue = SimplexNoise.Noise2D(x * noiseScale, 0)  
        local height = math.floor((noiseValue + 1) * maxHeight)  

        for y = 1, World.mapHeight do
            if y <= height then
                World.tiles[x][y] = Dirt.new()  
            else
                World.tiles[x][y] = nil  
            end
        end
    end

    World.tiles[5][8] = Dirt.new()  
end

function World.save(filename)
    local worldData = {
        tiles = {}
    }

    for x, column in pairs(World.tiles) do
        worldData.tiles[x] = {}
        for y, block in pairs(column) do
            if block and block.type then
                worldData.tiles[x][y] = {type = block.type}
            else
                worldData.tiles[x][y] = nil
            end
        end
    end

    local success, jsonData = pcall(json.encode, worldData)
    if not success then
        print("Error encoding JSON: " .. tostring(jsonData))
    else
        love.filesystem.write(filename, jsonData)
        print("World saved successfully to: " .. filename)  -- Success message
    end
end


function World.saveToFile(filename)
    local dataToSave = {
        tiles = {},  
        mapWidth = World.mapWidth,
        mapHeight = World.mapHeight
    }

    for i, tile in ipairs(World.tiles) do
        dataToSave.tiles[i] = {}
        for j, value in ipairs(tile) do

            if type(value) ~= "userdata" then
                dataToSave.tiles[i][j] = value
            else

                dataToSave.tiles[i][j] = nil  
            end
        end
    end

    local jsonData = json.encode(dataToSave)
    love.filesystem.write(filename, jsonData)
end

function World.isColliding(x, y)
    local gridX = math.floor(x / World.tileSize) + 1
    local gridY = math.floor(y / World.tileSize) + 1

    if gridX >= 1 and gridX <= World.mapWidth and gridY >= 1 and gridY <= World.mapHeight then
        local block = World.tiles[gridX][gridY]
        return block and block.hasHitbox 
    else
        return false
    end
end

function World.draw()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local startX = math.max(1, math.floor(Player.x / World.tileSize) - (screenWidth / World.tileSize) / 2)
    local startY = math.max(1, math.floor(Player.y / World.tileSize) - (screenHeight / World.tileSize) / 2)

    for x = startX, math.min(World.mapWidth, startX + (screenWidth / World.tileSize)) do
        for y = startY, math.min(World.mapHeight, startY + (screenHeight / World.tileSize)) do
            local block = World.tiles[x][y]
            if block then
                block:draw((x - 1) * World.tileSize, (y - 1) * World.tileSize)
            end
        end
    end
end

return World