local Control = {}

function Control.handleKeyPress(key, currentState, World)  
    if key == "return" then  
        if currentState == "title" then
            return "game"  
        end
    elseif key == "s" then  
        World.save("saved_world.json")  
    elseif key == "l" then  
        World.loadFromFile("saved_world.json")  
    end
    return currentState  
end

return Control
