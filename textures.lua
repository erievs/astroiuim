local Textures = {}

function Textures.load()


    Textures.playerStil = love.graphics.newImage("assets/player_walk_still.png")

    Textures.playerStilItem = love.graphics.newImage("assets/player_walk_still_item.png")

    Textures.playerWalk1 = love.graphics.newImage("assets/player_walk_1.png")

    Textures.playerWalk2 = love.graphics.newImage("assets/player_walk_2.png")

    Textures.playerWalk3 = love.graphics.newImage("assets/player_walk_3.png")

    Textures.playerWalk3 = love.graphics.newImage("assets/player_walk_3.png")

    Textures.playerWalk1Item = love.graphics.newImage("assets/player_walk_1_item.png")
    
    Textures.playerWalk2Item = love.graphics.newImage("assets/player_walk_2_item.png")

    Textures.playerWalk3Item = love.graphics.newImage("assets/player_walk_3_item.png")

    Textures.rightRustyKnifeTexture = love.graphics.newImage('assets/rusty_knife_right.png')
    Textures.leftRustyKnifeTexture = love.graphics.newImage('assets/rusty_knife_left.png')  
    Textures.luaRockPickaxe = love.graphics.newImage('assets/luarock_pickaxe.png')
end

return Textures