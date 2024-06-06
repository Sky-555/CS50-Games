VictoryState = Class{__includes = BaseState}

function VictoryState:enter(params)
    self.level = params.level
    self.health = params.health
    self.paddle = params.paddle
    self.score = params.score
    self.ball = {Ball(math.random(7))}
    self.highScores = params.highScores
    self.recoverPoints = params.recoverPoints
    self.newLevel = params.newLevel
    self.loadScore = params.loadScore
end

function VictoryState:update(dt)
    self.paddle:update(dt)

    for k, ball in pairs(self.ball) do
        ball.x = self.paddle.x + (self.paddle.width / 2) - 4
        ball.y = self.paddle.y - 8
    end

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('serve', {
            level = self.level + 1,
            bricks = LevelMaker:createMap(self.level + 1),
            health = self.health,
            paddle = self.paddle,
            score = self.score,
            ball = self.ball,
            highScores = self.highScores,
            recoverPoints = self.recoverPoints,
            newLevel = self.newLevel,
            loadScore = self.loadScore
        })
    end
end

function VictoryState:render()
    self.paddle:render()
    
    for k, ball in pairs(self.ball) do
        ball:render()
    end

    renderHealth(self.health)
    renderScore(self.score)

    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("Level " .. tostring(self.level) .. " complete!", 0, 
        VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Press Enter to enter the Level ' .. tostring(self.level + 1) .. ' !', 
        0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, 'center')
end