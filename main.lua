local Player = require("player")
local Textures = require("textures")
local World = require("world")
local Control = require("controls")
local Camera = require("camera")  

local currentState = "title"
local camera  

function love.load()
    Textures.load()   
    World.load()      
    Player.load(World) 
    camera = Camera.new()  

    local Beater3000 = require("items.beater3000")
    local beater3000 = Beater3000.new(Textures.beater3000)  

    table.insert(Player.inventory, beater3000) 
end

function love.update(dt)
    if currentState == "game" then
        Player.update(dt)

        camera:update(Player)
    end
end

function love.draw()
    if currentState == "title" then
        drawTitleScreen()  
    elseif currentState == "game" then
        camera:apply()  
        World.draw()      
        Player.draw()     

        
    end
end

function love.keypressed(key)
    currentState = Control.handleKeyPress(key, currentState, World)  
end

function drawTitleScreen()
    love.graphics.clear(0.1, 0.1, 0.1)  
    love.graphics.setColor(1, 1, 1)  
    love.graphics.setFont(love.graphics.newFont(48))  
    love.graphics.printf("My Game Title", 0, love.graphics.getHeight() / 4, love.graphics.getWidth(), "center")  
    love.graphics.setFont(love.graphics.newFont(24))  
    love.graphics.printf("Press Enter to Start", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")  
end