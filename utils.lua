
local Utils = {}


function Utils.worldToGrid(x, y, tileSize)
    return math.floor(x / tileSize) + 1, math.floor(y / tileSize) + 1
end


return Utils
