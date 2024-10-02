local EnvironmentManager = {}

-- Initialize the environment settings
function EnvironmentManager:init()
    self.dayTime = 0 -- A value from 0 to 1 representing the time of day (0 is dusk, 1 is night)
    self.colorTransitionSpeed = 0.001 -- Speed of the transition
    self.currentColor = {0.2, 0.3, 0.5} -- Starting color (dusk)
end

-- Update the environment based on the time of day
function EnvironmentManager:update(dt)
    -- Update dayTime based on the transition speed
    self.dayTime = self.dayTime + self.colorTransitionSpeed * dt
    if self.dayTime > 1 then
        self.dayTime = 1
    end

    -- Calculate the background color based on the time of day
    self.currentColor = self:calculateColor(self.dayTime)
end

-- Calculate the color based on the time of day
function EnvironmentManager:calculateColor(dayTime)
    local duskColor = {0.2, 0.3, 0.5} -- Dusk color (RGB)
    local nightColor = {0.05, 0.05, 0.2} -- Night color (RGB)

    -- Interpolate between dusk and night colors
    local r = duskColor[1] + (nightColor[1] - duskColor[1]) * dayTime
    local g = duskColor[2] + (nightColor[2] - duskColor[2]) * dayTime
    local b = duskColor[3] + (nightColor[3] - duskColor[3]) * dayTime

    return {r, g, b}
end

-- Draw the background color
function EnvironmentManager:draw()
    love.graphics.clear(self.currentColor[1], self.currentColor[2], self.currentColor[3])
end

return EnvironmentManager
