-- blocks/block.lua

local Block = {}

function Block.new(image, tier, hasHitbox)
    local self = {
        image = image,
        tier = tier,
        hasHitbox = hasHitbox,
        width = 16,  -- Assuming each block is 16x16
        height = 16,
    }

    function self.draw(x, y)
        love.graphics.draw(self.image, x, y)
    end

    return self
end

return Block
