PlayState = Class{__includes = BaseState}
function PlayState:init()
    self.transitionAlpha = 1

    self.boardHighlightX = 0
    self.boardHighlightY = 0

    self.rectHighlighted = false

    self.canInput = true

    -- tile we're currently highlighting (preparing to swap)
    self.highlightedTile = nil

    self.score = 0
    self.timer = 60

    self.inPlace = true

    -- set our Timer class to turn cursor highlight on and off
    Timer.every(0.5, function() self.rectHighlighted = not self.rectHighlighted end)

    -- subtract 1 from timer every second
    Timer.every(1, function()
        self.timer = self.timer - 1

        -- play warning sound on timer if we get low
        if self.timer <= 5 then
            gSounds['clock']:play()
        end
    end)
end

function PlayState:enter(params)
    self.level = params.level
    self.board = params.board or Board(VIRTUAL_WIDTH - 272, 16)
    self.score = params.score or 0
    self.scoreGoal = self.level * 1250
end

function PlayState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    if self.timer <= 0 then
        Timer.clear()
        
        gSounds['game-over']:play()

        gStateMachine:change('game-over', {score = self.score})
    end

    if self.score >= self.scoreGoal then
        Timer.clear()

        gSounds['next-level']:play()

        gStateMachine:change('begin-game', {
            level = self.level + 1,
            score = self.score
        })
    end

    if self.canInput then
        -- move cursor around based on bounds of grid, playing sounds
        if love.keyboard.wasPressed('up') then
            self.boardHighlightY = math.max(0, self.boardHighlightY - 1)
            gSounds['select']:play()
        elseif love.keyboard.wasPressed('down') then
            self.boardHighlightY = math.min(7, self.boardHighlightY + 1)
            gSounds['select']:play()
        elseif love.keyboard.wasPressed('left') then
            self.boardHighlightX = math.max(0, self.boardHighlightX - 1)
            gSounds['select']:play()
        elseif love.keyboard.wasPressed('right') then
            self.boardHighlightX = math.min(7, self.boardHighlightX + 1)
            gSounds['select']:play()
        end

        if love.keyboard.wasPressed('space') then

            local x = self.boardHighlightX + 1
            local y = self.boardHighlightY + 1
            
            if not self.highlightedTile then
                self.highlightedTile = self.board.tiles[y][x]
            elseif self.highlightedTile == self.board.tiles[y][x] then
                self.highlightedTile = nil
            elseif math.abs(self.highlightedTile.gridX - x) + math.abs(self.highlightedTile.gridY - y) > 1 then
                gSounds['error']:play()
                self.highlightedTile = nil
            else
                local newTile = self.board.tiles[y][x]

                self.highlightedTile.gridX, newTile.gridX = newTile.gridX, self.highlightedTile.gridX
                self.highlightedTile.gridY, newTile.gridY = newTile.gridY, self.highlightedTile.gridY

                self.board.tiles[self.highlightedTile.gridY][self.highlightedTile.gridX] =
                    self.highlightedTile

                self.board.tiles[newTile.gridY][newTile.gridX] = newTile

                Timer.tween(0.1, {
                    [self.highlightedTile] = {x = newTile.x, y = newTile.y},
                    [newTile] = {x = self.highlightedTile.x, y = self.highlightedTile.y}
                })
                :finish(function() 
                    self.inPlace = false
                    self:calculateMatches(self.highlightedTile, newTile) 
                end)
            end
        end
    end

    Timer.update(dt)
end

function PlayState:calculateMatches(highlightedTile, swappedTile)
    self.canInput = false

    local matches = self.board:calculateMatches()

    if matches then
        gSounds['match']:stop()
        gSounds['match']:play()

        self.highlightedTile = nil
        
        self.board:removeMatches()

        for k, tile in pairs(self.board.removedTiles) do
            local shinyScore = tile.shiny == true and 200 or 0
            
            self.score = self.score + (40 + 20 * tile.variety + shinyScore)
            self.timer = self.timer + 1
        end

        self.board.removedTiles = {}

        local tilestoFall = self.board:getFallingTiles()

        Timer.tween(0.5, tilestoFall):finish(function() self:calculateMatches() end)
    else
        -- only revert back if first swap is unsucessful
        if self.highlightedTile then
            gSounds['error']:play()

            -- unmatchedTile is previously self.highlightedTile
            -- swappedTile is previously newTile
            local unmatchedTile = highlightedTile

            unmatchedTile.gridX, swappedTile.gridX = swappedTile.gridX, unmatchedTile.gridX
            unmatchedTile.gridY, swappedTile.gridY = swappedTile.gridY, unmatchedTile.gridY

            self.board.tiles[swappedTile.gridY][swappedTile.gridX] = swappedTile

            self.board.tiles[unmatchedTile.gridY][unmatchedTile.gridX] = unmatchedTile

            Timer.tween(0.2, {
                [swappedTile] = {x = unmatchedTile.x, y = unmatchedTile.y},
                [unmatchedTile] = {x = swappedTile.x, y = swappedTile.y}
            })
            :finish(function() 
                self.inPlace = true
                self.highlightedTile = nil 
            end)               
        end

        for y = 1, 8 do
            for x = 1, 8 do
                if self.board.tiles[y][x].y == (y - 1) * 32 then
                    self.inPlace = true
                end
            end
        end
    
        if self.inPlace then
            swappable = self.board:possibleSwap2()
        end
    
        if not swappable then
            self.canInput = self.board:shuffle()
            self.matches = {}
            self.shinyTiles = {}
        else
            self.canInput = true
            self.matches = {}
            self.shinyTiles = {}
        end
    end
end

function PlayState:render()
    self.board:render()

    if self.highlightedTile then
        love.graphics.setBlendMode('add')

        love.graphics.setColor(1, 1, 1, 96/255)
        love.graphics.rectangle('fill', 32 * (self.highlightedTile.gridX - 1) + VIRTUAL_WIDTH - 272, 
            32 * (self.highlightedTile.gridY - 1) + 16, 32, 32)

        love.graphics.setBlendMode('alpha')
    end

    love.graphics.printf(tostring(self.highlightedTIle.gridX), 20, 24, VIRTUAL_WIDTH, 'center')

    -- only show possibles when it is not shuffling or tiles falling
    if not self.board.reset then
        if self.canInput then
            self.board:showPossibles()
        end
    end

    if self.rectHighlighted then
        love.graphics.setColor(217/255, 87/255, 99/255, 1)
    else
        love.graphics.setColor(172/255, 50/255, 50/255, 1)
    end

    -- set transparent rect highlight when it is shuffling
    if self.board.reset then
        love.graphics.setColor(0, 0, 0, 0)
    end

    love.graphics.setLineWidth(4)
    love.graphics.rectangle('line', 32 * self.boardHighlightX + VIRTUAL_WIDTH - 272, 
        32 * self.boardHighlightY + 16, 32, 32)

    love.graphics.setColor(56/255, 56/255, 56/255, 234/255)
    love.graphics.rectangle('fill', 16, 16, 186, 116, 4)

    love.graphics.setColor(99/2555, 155/255, 1, 1)
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Level: ' .. tostring(self.level), 20, 24, 182, 'center')
    love.graphics.printf('Score: ' .. tostring(self.score), 20, 52, 182, 'center')
    love.graphics.printf('Goal : ' .. tostring(self.scoreGoal), 20, 80, 182, 'center')
    love.graphics.printf('Timer: ' .. tostring(self.timer), 20, 108, 182, 'center')
end