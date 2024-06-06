Player = Class{__includes = Entity}

function Player:init(def)
    Entity.init(self, def)
    self.occupied = false

    Event.on('throw', function(dt)
        self.pot:flying(dt)
    end)
end

function Player:update(dt)
    Entity.update(self, dt)
end

function Player:collides(target)
    local selfY, selfHeight = self.y + self.height / 2, self.height - self.height / 2
    
    return not (self.x + self.width < target.x + 1 or self.x + 1 > target.x + target.width or
                selfY + selfHeight < target.y + 1 or selfY + 1 > target.y + target.height)
end

function Player:render()
    Entity.render(self)

    -- love.graphics.setColor(1, 0, 1, 1)
    -- love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    -- love.graphics.setColor(1, 1, 1, 1)
end