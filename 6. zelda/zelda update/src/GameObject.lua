GameObject = Class{}

function GameObject:init(def, x, y)
    self.type = def.type
    self.texture = def.texture
    self.frame = def.frame or 1 

    self.solid = def.solid

    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states

    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height

    self.scaleX = 1
    self.spawned = false
    self.consumable = def.consumable or false

    self.onCollide = function() end
    self.onConsume = function() end
end

function GameObject:update(dt)
    
end

function GameObject:collides(target)
    return not (target.x > self.x + self.width or self.x > target.x + target.width or
                target.y + target.offsetY > self.y + self.height or self.y > target.y + target.height + target.offsetY)
end

function GameObject:render(adjacentOffsetX, adjacentOffsetY)
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
        self.state == 'half' and self.x + adjacentOffsetX + self.width or self.x + adjacentOffsetX, 
        self.y + adjacentOffsetY,
        0,
        self.scaleX,
        1)

    -- love.graphics.setColor(1, 0, 1, 1)
    -- love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    -- love.graphics.setColor(1, 1, 1, 1)
end

function GameObject:renderParticles() end