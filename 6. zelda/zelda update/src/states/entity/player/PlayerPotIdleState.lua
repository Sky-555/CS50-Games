PlayerPotIdleState = Class{__includes = EntityIdleState}

function PlayerPotIdleState:init(player)
    self.entity = player
    self.entity:changeAnimation('pot-idle-' .. tostring(self.entity.direction))

    self.entity.offsetX = 0
    self.entity.offsetY = 5
end

function PlayerPotIdleState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or 
        love.keyboard.isDown('down') or love.keyboard.isDown('up') then
            self.entity:changeState('pot-walk')
    end

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gSounds['throw']:play()
        self.entity:changeState('idle')
        self.entity:changeAnimation('idle-' .. tostring(self.entity.direction))
        self.entity.pot.fired = true
    end
end

function PlayerPotIdleState:render()
    EntityIdleState.render(self)
end