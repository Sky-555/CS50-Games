PlayerPotLiftState = Class{__includes = BaseState}

function PlayerPotLiftState:init(player)
    self.entity = player

    self.pot = self.entity.pot

    self.entity:changeAnimation('pot-lift-' .. tostring(self.entity.direction))

    self.entity.offsetX = 0
    self.entity.offsetY = 5
end

function PlayerPotLiftState:update(dt)
    Timer.after(0.075, function()
        Timer.tween(0.075,{
        [self.pot] = {x = self.entity.x, y = self.entity.y - 10}
        }):finish(function()
            self.pot.lifted = true
            Timer:clear() 
            self.entity:changeState('pot-idle')
        end)
    end)
end

function PlayerPotLiftState:render()
    EntityIdleState.render(self)
end