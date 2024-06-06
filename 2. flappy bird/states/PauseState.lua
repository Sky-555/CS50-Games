-- Pause state stops all the udpating including musics and backgrounds scrolling, while keeping
-- datas of the previous states.

PauseState = Class{__includes = PlayState}

paused = false

PAUSED_ICON = love.graphics.newImage('paused icon.png')

-- takes in all the parameters of the last update of play state so that they get preserved when play state 
-- initialised again.
function PauseState:enter(params)
    self.bird = params.bird
    self.pipePairs = params.pipePairs
    self.timer = params.timer
    self.lastY = params.lastY
    self.score = params.score
    self.newPipe = params.newPipe
    self.paused = params.paused
    paused = self.paused
end

-- 
function PauseState:update(dt)
    if love.keyboard.wasPressed('p') then
        sounds.pause:play()
        gStateMachine:change('play', {
            bird = self.bird,
            pipePairs = self.pipePairs,
            timer = self.timer,
            lastY = self.lastY,
            score = self.score,
            newPipe = self.newPipe,
            paused = false
        })
    end
end

function PauseState:render()
    love.graphics.setFont(flappyFont)
    -- offset x and y coordinate to shrink at the middle of the icon because the icon is too large
    love.graphics.draw(PAUSED_ICON, VIRTUAL_WIDTH/2 - 90, VIRTUAL_HEIGHT/2 - 90, 0, 0.5, 0.5)
    love.graphics.printf('Hit p to continue playing', 10, 40, VIRTUAL_WIDTH, 'center')

    for k, pipes in pairs(self.pipePairs) do
        pipes:render()
    end

    love.graphics.setFont(flappyFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 5, VIRTUAL_WIDTH, 'left')

    self.bird:render()
end