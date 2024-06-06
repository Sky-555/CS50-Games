Projectile = Class{__includes = GameObject}

function Projectile:init(def, x, y, player, room)
    GameObject.init(self, def, x, y)
    self.dx = 150
    self.player = player
    self.room = room

    self.aboveHeadY = 10
    self.lifted = false
    self.fired = false
    self.exploded = false

    self.psystem = love.graphics.newParticleSystem(gTextures['particles'], 32)

    self.psystem:setParticleLifetime(0.5, 1)
    self.psystem:setLinearAcceleration(-30, -30, 30, 30)
    self.psystem:setEmissionArea('normal', 10, 10, 0, true)
end

function Projectile:update(dt)
    self.psystem:update(dt)

    if self.lifted then
        self.x = self.player.x
        self.y = self.player.y - self.aboveHeadY
    end
    
    if self.exploded then
        if self.psystem:getCount() == 0 then
            self.remove = true
        end
    end
end

-- for throwing event
function Projectile:flying(dt)
    if not self.exploded then
        self:fire(dt)
    end

    if self.remove then
        self.player.pot = nil

        for k, object in pairs(self.room.objects) do
            if object == self then
                table.remove(self.room.objects, k)
            end
        end

        self.player:changeState('idle')
    end
end

function Projectile:fire(dt)
    local maxDistance = TILE_SIZE * 4
    local heightDiff = self.player.height - self.player.offsetY

    self.dy = heightDiff / (maxDistance / self.dx)

    if self.lifted then
        self.initialX = self.x
        self.initialY = self.y
        self.initialDirection = self.player.direction
    end

    self.lifted = false
    self.player.occupied = false

    for k, entity in pairs(self.room.entities) do
        if entity:collides(self) then
            entity:damage(1)
            self:explode()
        end
    end

    if self.initialDirection == 'left' then
        local targetX = self.initialX - maxDistance

        self.x = math.max(MAP_RENDER_OFFSET_X, math.max(self.x - self.dx * dt, targetX))
        self.y = math.min(self.y + self.dy * dt, self.initialY + heightDiff)

        if self.x <= MAP_RENDER_OFFSET_X + 3 or self.x <= targetX then
            self:explode() 
        end
    elseif self.initialDirection == 'right' then
        local targetX = self.initialX + maxDistance

        self.x = math.min(VIRTUAL_WIDTH - TILE_SIZE * 2, math.min(self.x + self.dx * dt, targetX))
        self.y = math.min(self.y + self.dy * dt, self.initialY + heightDiff)

        if self.x >= VIRTUAL_WIDTH - TILE_SIZE * 2 - 1 or self.x >= targetX then
            self:explode()
        end
    elseif self.initialDirection == 'down' then
        local targetY = self.initialY + maxDistance

        self.y = math.min(VIRTUAL_HEIGHT - TILE_SIZE * 2, math.min(self.y + self.dx * dt, targetY + heightDiff))
        
        if self.y >= VIRTUAL_HEIGHT - TILE_SIZE * 2 - 1 or self.y >= targetY + heightDiff then
            self:explode()
        end
    elseif self.initialDirection == 'up' then
        local targetY = self.initialY - maxDistance

        self.y = math.max(MAP_RENDER_OFFSET_Y, math.max(self.y - self.dx * dt, targetY + heightDiff))
        
        if self.y <= MAP_RENDER_OFFSET_Y + 3 or self.y <= targetY + heightDiff then
            self:explode()
        end
    end
end

function Projectile:explode()
    gSounds['throw']:stop()
    gSounds['explode']:play()

    self.psystem:setColors(226/255, 88/255, 34/255, 1)
    self.psystem:emit(32)
    
    self.player.occupied = false
    self.exploded = true
end

function Projectile:render(adjacentOffsetX, adjacentOffsetY)
    if not self.exploded then
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY)
    end
    
    -- love.graphics.setColor(1, 0, 1, 1)
    -- love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    -- love.graphics.setColor(1, 1, 1, 1)
end

function Projectile:renderParticles()
    love.graphics.draw(self.psystem, self.x + 8, self.y + 8)
end