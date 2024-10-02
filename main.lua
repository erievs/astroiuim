local Player = require("player")
local Textures = require("textures")
local World = require("world")
local Control = require("controls")
local Camera = require("camera")  
local RustyKnife = require("items.rustyknife")  
local Ui = require("ui")
local LuaRockPickaxe = require("items.luarockpickaxe")
local EnvironmentManager = require("environmentmanager")
local currentState = "title"
local camera  
local hotbar  
local ui 

function love.load()
    Textures.load()   
    World.load()      
    Player.load(World) 
    camera = Camera.new()  

    EnvironmentManager:init()

    local rustyknife = RustyKnife.new() 

    local luarockpickaxe = LuaRockPickaxe.new() 

    Player.addItem(rustyknife, 1)
    Player.addItem(luarockpickaxe, 2) 

    ui = Ui.new(Player.inventory)  


end

function love.update(dt)
    if currentState == "game" then
        Player.update(dt, world)
        camera:update(Player)
        EnvironmentManager:update(dt)

    end
end

function love.draw()
    if currentState == "title" then
        drawTitleScreen()  
    elseif currentState == "game" then
        camera:apply()  
        EnvironmentManager:draw()
        World.draw()      
        
        Player.draw()   

     
 
  
        love.graphics.push() 
        love.graphics.origin()  
        ui:draw(100)  
        love.graphics.pop()
        
    end

end

function love.keypressed(key)

    if key >= "1" and key <= "5" then
        local itemIndex = tonumber(key)  
            Player.currentItemIndex = itemIndex 
            ui:selectItem(itemIndex)
    end

    currentState = Control.handleKeyPress(key, currentState, World)  
end

function drawTitleScreen()
    love.graphics.clear(0.1, 0.1, 0.1)  
    love.graphics.setColor(1, 1, 1)  
    love.graphics.setFont(love.graphics.newFont(48))  
    love.graphics.printf("Astroium", 0, love.graphics.getHeight() / 4, love.graphics.getWidth(), "center")  
    love.graphics.setFont(love.graphics.newFont(24))  
    love.graphics.printf("Press Enter to Start", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")  
end
