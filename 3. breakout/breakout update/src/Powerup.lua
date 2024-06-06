Powerup = Class{}

function Powerup:init()
    self.x = math.random(0, VIRTUAL_WIDTH - 16)
    self.y = -16
    self.width = 16
    self.height = 16
    self.dy = 50
    self.spawned = false
    self.collected = false
end

function Powerup:caught(paddle)
    -- check for collison between powerup and paddle
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end
    
    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end

    -- to stop the powerup from spawning again in that level
    self:reset()
    self.collected = true
    return true
end

function Powerup:update(dt)
    self.y = self.y + self.dy * dt
end

function Powerup:reset()
    self.x = math.random(0, VIRTUAL_WIDTH - 16)
    self.y = -16
end

function Powerup:effects() end

function Powerup:render() end