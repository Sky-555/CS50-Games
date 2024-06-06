PlayState = Class{__includes = BaseState}
function PlayState:init()
    self.transitionAlpha = 1

    self.boardHighlightX = 0
    self.boardHighlightY = 0

    self.rectHighlighted = false

    self.canInput = true

    -- tile we're currently highlighting (preparing to swap)
    self.highlightedTile = nil

    -- flag for clicking cause switching 
    self.switchHighlight = false

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
        if self.inPlace then
            Timer.clear()

            gSounds['next-level']:play()

            gStateMachine:change('begin-game', {
                level = self.level + 1,
                score = self.score
            })
        end
    end

    -- mouse coordinates in virtual resolution 
    local X, Y = push:toGame(love.mouse.getPosition())
        
    -- determines which tile player is hovering on
    if Y > self.board.y and Y < self.board.y + 256 then
        if X > self.board.x and X < self.board.x + 256 then
            self.boardHighlightX = math.floor((X - self.board.x) / 32)
            self.boardHighlightY = math.floor((Y - 16) / 32)
        end
    end

    if love.mouse.wasReleased(1) then
        self.switchHighlight = false
    end

    if self.board.shuffleFinish then
        self.canInput = true
        self.board.shuffleFinish = false
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

        if love.keyboard.wasPressed('space') or love.mouse.isDown(1) then
            local x = self.boardHighlightX + 1
            local y = self.boardHighlightY + 1
            
            if not self.highlightedTile then
                -- prevent the tile from switching between highlighted and not highlighted every frame when holding click
                if not self.switchHighlight then
                    self.highlightedTile = self.board.tiles[y][x]
                    self.switchHighlight = true

                    if love.keyboard.wasPressed('space') then
                        self.switchHighlight = false
                    end
                else
                    if love.mouse.wasReleased(1) then
                        self.switchHighlight = false
                    end
                end
            elseif self.highlightedTile == self.board.tiles[y][x] then
                if not self.switchHighlight then
                    self.highlightedTile = nil
                    self.switchHighlight = true

                    if love.keyboard.wasPressed('space') then
                        self.switchHighlight = false
                    end
                else
                    if love.mouse.wasReleased(1) then
                        self.switchHighlight = false
                    end
                end
            elseif math.abs(self.highlightedTile.gridX - x) + math.abs(self.highlightedTile.gridY - y) > 1 then
                if love.keyboard.wasPressed('space') then
                    gSounds['error']:play()
                    self.highlightedTile = nil
                else
                    self.highlightedTile = self.board.tiles[y][x]
                    self.switchHighlight = true
                end
            else
                local newTile = self.board.tiles[y][x]

                self.canInput = false

                self.board:swapTiles(self.highlightedTile, newTile)
                
                Timer.tween(0.1, {
                    [self.highlightedTile] = {x = newTile.x, y = newTile.y},
                    [newTile] = {x = self.highlightedTile.x, y = self.highlightedTile.y}
                })
                :finish(function()
                    self.firstSwap = true
                    self.inPlace = false
                    self:calculateMatches(self.highlightedTile, newTile)
                    self.highlightedTile = nil
                end)
            end

            self.board.tiles[y][x].psystem:emit(3)
        end
    end

    for y = 1, 8 do
        for x = 1, 8 do
            self.board.tiles[y][x]:update(dt)
        end
    end

    Timer.update(dt)
end

function PlayState:calculateMatches(highlightedTile, swappedTile)
    local matches = self.board:calculateMatches()

    if matches then
        self.firstSwap = false
        gSounds['match']:stop()
        gSounds['match']:play()

        self.board:removeMatches()

        for k, tile in pairs(self.board.removedTiles) do
            local shinyScore = tile.shiny == true and 200 or 0
            
            self.score = self.score + (40 + 20 * (tile.variety - 1) + shinyScore)
            self.timer = self.timer + 1
        end

        self.board.removedTiles = {}

        local tilestoFall = self.board:getFallingTiles()

        Timer.tween(0.4, tilestoFall):finish(function() self:calculateMatches() end)
    else
        -- only revert back if it is first swap and is unsuccessful
        if self.firstSwap then
            gSounds['error']:play()

            -- highlightedTile is previously self.highlightedTile
            -- swappedTile is previously newTile
            self.board:swapTiles(highlightedTile, swappedTile)

            Timer.tween(0.2, {
                [swappedTile] = {x = highlightedTile.x, y = highlightedTile.y},
                [highlightedTile] = {x = swappedTile.x, y = swappedTile.y}
            })
            :finish(function()
                self.firstSwap = false
            end)               
        end

        for y = 1, 8 do
            for x = 1, 8 do
                if self.board.tiles[y][x].y == (y - 1) * 32 then
                    self.inPlace = true
                end
            end
        end
    
        -- better visual effects and players experience
        if self.inPlace then
            swappable = self.board:possibleSwap2()
        end
    
        if swappable then 
            self.canInput = true
        else
            self.board:shuffle()
        end
        self.matches = {}
        self.shinyTiles = {}
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

    -- only show possibles when it is not shuffling or tiles are in place
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