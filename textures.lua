local Textures = {}

function Textures.load()
    Textures.playerLeft = love.graphics.newImage("assets/player_walk_left.png")
    Textures.playerRight = love.graphics.newImage("assets/player_walk_right.png")
    Textures.beater3000 = love.graphics.newImage("assets/beater3000.png") 
end

return Textures