VictoryState = Class{__includes = BaseState}

function VictoryState:enter(params)
    self.levelNum = params.levelNum
    self.score = params.score
    self.background = math.random(3)
end

function VictoryState:update(dt)
    if not gSounds['win']:isPlaying() then
        gStateMachine:change('play', {
            levelNum = self.levelNum + 1,
            score = self.score
        })
        gSounds['music']:play()
    end
end

function VictoryState:render()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 0, 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 0,
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)

    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(tostring(self.score), 5, 5)
    love.graphics.printf('Level ' .. tostring(self.levelNum), -3, 5, VIRTUAL_WIDTH, 'right')
    love.graphics.printf('Congratulations, Entering Level ' .. tostring(self.levelNum + 1), 
        1, VIRTUAL_HEIGHT / 2 - 20 + 1, VIRTUAL_WIDTH, 'center')

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(tostring(self.score), 4, 4)
    love.graphics.printf('Level ' .. tostring(self.levelNum), -4, 4, VIRTUAL_WIDTH, 'right')
    love.graphics.printf('Congratulations, Entering Level ' .. tostring(self.levelNum + 1), 
        0, VIRTUAL_HEIGHT / 2 - 20, VIRTUAL_WIDTH, 'center')
end