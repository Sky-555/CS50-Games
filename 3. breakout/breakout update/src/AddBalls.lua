AddBalls = Class{__includes = Powerup}

function AddBalls:effects(paddle, balls)
    gSounds['powerup']:play()
    
    for i = 1, 2 do
        newBall = Ball(math.random(7))
        newBall.x = paddle.x + paddle.width / 2 - 4
        newBall.y = paddle.y - 8
        table.insert(balls, newBall)
    end

    return balls
end

function AddBalls:render()
    love.graphics.draw(gTexture['main'], gFrames['powerups'][1], self.x, self.y)
end