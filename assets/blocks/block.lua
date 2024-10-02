local Block = {}

function Block.new(image, tier, hasHitbox)
    local self = {
        image = image,
        tier = tier,
        hasHitbox = hasHitbox,
        width = 16,
        height = 16,
        x = 0,
        y = 0,
    }

    function self:draw()
        love.graphics.draw(self.image, self.x, self.y)
    end

    function self:setPosition(x, y)
        self.x = x
        self.y = y
    end

    function self:checkCollision(other)
        if not self.hasHitbox or not other.hasHitbox then
            return false
        end

        return self.x < other.x + other.width and
               self.x + self.width > other.x and
               self.y < other.y + other.height and
               self.y + self.height > other.y
    end

    function self:getTier()
        return self.tier
    end

    -- Highlight method
    function self:highlight()
        love.graphics.setColor(1, 1, 0, 0.5) -- Yellow color for highlight
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        love.graphics.setColor(1, 1, 1, 1) -- Reset color
        -- Log block coordinates
        print("Block Coordinates: X=" .. self.x .. ", Y=" .. self.y)
    end

    return self
end

return Block
