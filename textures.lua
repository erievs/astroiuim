local Textures = {}

function Textures.load()
    
    Textures.playerLeft = love.graphics.newImage("assets/player_walk_left.png")
    Textures.playerRight = love.graphics.newImage("assets/player_walk_right.png")
    Textures.rightRustyKnifeTexture = love.graphics.newImage('assets/rusty_knife_right.png')
    Textures.leftRustyKnifeTexture = love.graphics.newImage('assets/rusty_knife_right.png')
    Textures.luaRockPickaxe = love.graphics.newImage('assets/luarock_pickaxe.png')

end

return Textures