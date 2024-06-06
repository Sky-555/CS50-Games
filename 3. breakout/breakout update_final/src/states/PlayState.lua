PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
    self.ball = params.ball
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.level = params.level

    self.highScores = params.highScores
    self.recoverPoints = params.recoverPoints

    -- store the previous recover or paddle level up score
    self.loadScore = params.loadScore

    self.powerups = {gPowerups['key'], gPowerups['add-balls']}

    self.paused = false
    self.timer = 0
    self.spawnTime = getRandomTime()

    -- flag for entering a new level
    self.newLevel = params.newLevel
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    self:powerupSpawn(dt)

    self.paddle:update(dt)

    for k, ball in pairs(self.ball) do
        ball:update(dt)

        if ball:collide(self.paddle) then
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            if ball.x < self.paddle.x + self.paddle.width / 2 and self.paddle.dx < 0 then
                ball.dx = -50 - (8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
            elseif ball.x > self.paddle.x + self.paddle.width / 2 and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()
        end

        for k, brick in pairs(self.bricks) do
            if brick.inPlay and ball:collide(brick) then

                -- add 300 points if hit unlocked bricks
                if not brick.locked then
                    if brick.unlocked then
                        self.score = self.score + 300
                    else
                        self.score = self.score + (brick.tier * 200 + brick.colour * 25)
                    end
                end
                
                brick:hit()

                -- linear incerase in points needed to heal
                if self.score >= (self.loadScore['recover'] + self.recoverPoints) then
                    if self.health < 3 then
                        self.health = math.min(3, self.health + 1)
                        self.recoverPoints = self.recoverPoints + 1000
                        gSounds['recover']:play()
                        self.loadScore['recover'] = getCurrentScore(self.score)
                    end
                end

                -- need 3000 points higher than the previous paddle level up
                if self.score >= self.loadScore['paddle'] + 3000 then
                    if self.paddle.size < 4 then
                        gSounds['paddle-up']:play()
                        self.paddle.size = math.min(4, self.paddle.size + 1)
                        self.loadScore['paddle'] = getCurrentScore(self.score)
                    end
                end

                if self:checkVictory() then
                    gSounds['victory']:play()
                    for k, powerup in pairs(self.powerups) do
                        powerup.spawned = false
                        powerup:reset()
                    end

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        ball = self.ball,
                        highScores = self.highScores,
                        recoverPoints = self.recoverPoints,
                        newLevel = true,
                        loadScore = self.loadScore
                    })
                end

                if ball.x + 2 < brick.x and ball.dx > 0 then
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32
                elseif ball.y < brick.y then
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8
                else
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                ball.dy = ball.dy * 1.02

                break
            end
        end

        if ball.y > VIRTUAL_HEIGHT then
            gSounds['hurt']:stop()
            gSounds['hurt']:play()
            local index = table.index(self.ball, ball)
            table.remove(self.ball, index)

            if #self.ball == 0 then
                if self.paddle.size > 1 then
                    gSounds['paddle-down']:play()
                end
                self.health = self.health - 1
                -- reduce the paddle size by one
                self.paddle.size = math.max(1, self.paddle.size - 1)
                self.loadScore['recover'] = getCurrentScore(self.score)
                self.loadScore['paddle'] = getCurrentScore(self.score)
            end

            if self.health == 0 then
                gStateMachine:change('game-over', {
                    score = self.score,
                    highScores = self.highScores
                })
            else
                if #self.ball == 0 then
                    for k, powerup in pairs(self.powerups) do
                        powerup.spawned = false
                        powerup:reset()
                    end
                    gStateMachine:change('serve', {
                        level = self.level,
                        paddle = self.paddle,
                        bricks = self.bricks,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        recoverPoints = self.recoverPoints,
                        newLevel = self.newLevel,
                        loadScore = self.loadScore
                    })
                end
            end
        end
    end

    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    self.paddle:render()

    for k, ball in pairs(self.ball) do
        ball:render()
    end

    for k, brick in pairs(self.bricks) do
        brick:render()
        brick:renderParticles()
    end

    for k, powerup in pairs(self.powerups) do
        powerup:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end

    return true
end

function PlayState:powerupSpawn(dt)
    local key = self.powerups[1]
    local add_balls = self.powerups[2]

    -- makes key powerup harder to catch
    key.dy = 60 + 2 * self.level
    add_balls.dy = 50 + 2 * self.level

    if self.newLevel then
        key.collected = false
        add_balls.collected = false
        self.newLevel = not self.newLevel
    end

    if not key.spawned and not add_balls.spawned then
        self.timer = self.timer + dt
    end

    -- if add-balls is not collected yet and key not collected yet
    if not add_balls.collected then
        local locked = false

        if self.timer > self.spawnTime then
            for k, brick in pairs(self.bricks) do
                if brick.locked then
                    self.timer = 0
                    key.spawned = true
                    locked = true
                end
            end
        end

        if not locked then
            if self.timer > self.spawnTime then
                add_balls:update(dt)
                self.timer = 0
                add_balls.spawned = true
            end
        end
    else
        -- after first collection of add-balls, next spawn will be 30 seconds
        if self.timer > 20 then
            add_balls:update(dt)
            self.timer = 0
            add_balls.spawned = true
        end
    end

    for k, powerup in pairs(self.powerups) do
        if powerup.spawned then
            powerup:update(dt)
        end

        if powerup:caught(self.paddle) then
            if powerup == key then
                powerup:effects(self.bricks)
                locked = false
            else
                balls = powerup:effects(self.paddle, self.ball)
                self.ball = balls
            end
            powerup.spawned = false
        end
        
        if powerup.y > VIRTUAL_HEIGHT then
            powerup.spawned = false
            powerup:reset()
        end
    end
end