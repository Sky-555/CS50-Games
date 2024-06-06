ScoreState = Class{__includes = BaseState}

local GOLD_MEDAL = love.graphics.newImage('Gold Medal.png')
local SILVER_MEDAL = love.graphics.newImage('Silver Medal.png')
local BRONZE_MEDAL = love.graphics.newImage('Bronze Medal.png')

function ScoreState:enter(params)
    self.score = params
end

function ScoreState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Oof! Your bird died!', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')

    if self.score >= 15 then
        love.graphics.printf('You earned a gold medal! Keep it up!', 0, 120, VIRTUAL_WIDTH, 'center')
        love.graphics.draw(GOLD_MEDAL, VIRTUAL_WIDTH/2 - 32, 130)
    elseif self.score >= 10 then
        love.graphics.printf('You earned a silver medal! Score 15 to earn a gold!', 0, 120, VIRTUAL_WIDTH, 'center')
        love.graphics.draw(SILVER_MEDAL, VIRTUAL_WIDTH/2 - 32, 130)
    elseif self.score >= 5 then
        love.graphics.printf('You earned a bronze medal! Score 10 to earn a silver!', 0, 120, VIRTUAL_WIDTH, 'center')
        love.graphics.draw(BRONZE_MEDAL, VIRTUAL_WIDTH/2 - 32, 130)
    else
        love.graphics.printf('Score 5 to earn a bronze', 0, 120, VIRTUAL_WIDTH, 'center')
    end

    love.graphics.printf('Press Enter to Play Again!', 0, 180, VIRTUAL_WIDTH, 'center')
end