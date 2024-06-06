CountdownState = Class{__includes = BaseState}

COUNTDOWN_TIME = 0.75

function CountdownState:init()
    self.count = 3
    self.timer = 0
end

function CountdownState:update(dt)
    self.timer = self.timer + COUNTDOWN_TIME * dt
    if self.timer > COUNTDOWN_TIME then
        self.count = self.count - 1
        self.timer = 0
    end

    if self.count == 0 then
        gStateMachine:change('play')
    end
end

function CountdownState:render()
    love.graphics.setFont(hugeFont)
    love.graphics.printf(self.count, 0, 50, VIRTUAL_WIDTH, 'center')
end