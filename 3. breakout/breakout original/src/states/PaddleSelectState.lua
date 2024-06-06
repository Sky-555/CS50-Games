PaddleSelectState = Class{__includes = BaseState}

function PaddleSelectState:enter(params)
    self.highScores = params.highScores
end

function PaddleSelectState:init()
    self.currentPaddle = 1
end

function PaddleSelectState:update(dt)
    if love.keyboard.wasPressed('left') then
        if self.currentPaddle == 1 then
            gSounds['no-select']:play()
        else
            self.currentPaddle = self.currentPaddle - 1
            gSounds['select']:play()
        end
    elseif love.keyboard.wasPressed('right') then
        if self.currentPaddle == 4 then
            gSounds['no-select']:play()
        else
            self.currentPaddle = self.currentPaddle + 1
            gSounds['select']:play()
        end
    end

    if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
        gSounds['confirm']:play()

        gStateMachine:change('serve', {
            paddle = Paddle(self.currentPaddle),
            bricks = LevelMaker.createMap(1),
            health = 3,
            score = 0,
            level = 1,
            highScores = self.highScores,
            recoverPoints = 5000
        })
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PaddleSelectState:render()
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf("Select your paddle with left and right!", 0, VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(gFonts['small'])
    love.graphics.printf("(Press Enter to continue!)", 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')

    if self.currentPaddle == 1 then
        love.graphics.setColor(40/255, 40/255, 40/255, 127/255)
    end

    love.graphics.draw(gTexture['arrow'], gFrames['arrows'][1], VIRTUAL_WIDTH / 4 - 24, 2/3 * VIRTUAL_HEIGHT)

    love.graphics.setColor(1, 1, 1, 1)

    if self.currentPaddle == 4 then
        love.graphics.setColor(40/255, 40/255, 40/255, 127/255)
    end

    love.graphics.draw(gTexture['arrow'], gFrames['arrows'][2], 0.75 * VIRTUAL_WIDTH, 2/3 * VIRTUAL_HEIGHT )

    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.draw(gTexture['main'], gFrames['paddles'][2 + 4 * (self.currentPaddle - 1)],
        VIRTUAL_WIDTH / 2 - 32, 2/3 *VIRTUAL_HEIGHT)
end