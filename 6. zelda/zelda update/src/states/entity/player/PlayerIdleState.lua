PlayerIdleState = Class{__includes = EntityIdleState}

function PlayerIdleState:enter(params)
    
    -- render offset for spaced character sprite (negated in render function of state)
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerIdleState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('walk')
    end

    if love.keyboard.wasPressed('space') then
        self.entity:changeState('swing-sword')
    end

    if self.entity.pot and self.entity.pot.fired then
        Event.dispatch('throw', dt)
    end

    -- to reset player positions when colliding with pots
    for k, object in pairs(self.dungeon.currentRoom.objects) do
        if self.entity:collides(object) and not object.fired and not object.lifted and object.solid then
            if self.entity.direction == 'left' then
                self.entity.x = object.x + object.width
            elseif self.entity.direction == 'right' then
                self.entity.x = object.x - self.entity.width
            elseif self.entity.direction == 'down' then
                self.entity.y = object.y - self.entity.height
            elseif self.entity.direction == 'up' then
                self.entity.y = object.y + object.height
            end
        end
    end
end