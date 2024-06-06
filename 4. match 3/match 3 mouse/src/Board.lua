Board = Class{}

function Board:init(x, y, level)
    self.x = x
    self.y = y
    self.matches = {}
    self.pairs = {}
    self.level = level
    self.shinyTiles = {}

    self.reset = false
    self.possibles = {}
    self.removedTiles = {}
    self.shuffleFinish = false

    self.shades, self.colours = self:generateColours()
    self.patterns = self:generatePatterns()    
    self:initialiseTiles()
end

function Board:initialiseTiles()
    self.tiles = {}

    for tileY = 1, 8 do
        table.insert(self.tiles, {})

        for tileX = 1, 8 do
            table.insert(self.tiles[tileY], Tile(tileX, tileY, 
                self:getColours(), self:getPatterns()))
        end
    end

    self.shinyTiles = {}

    while self:calculateMatches() or not self:possibleSwap() do
        self:initialiseTiles()
    end
end

function Board:generateColours()
    local shades = {}
    local newColour = false
    local colours = {}

    -- level 1 starts with 6 colours, cap at 8 
    local colourNum = math.min(8, 6 + math.floor(self.level / 2))

    for i = 1, colourNum do
        newColour = false
        while not newColour do
            local colour = math.random(8)
            local shadesTable = gColourPackage[colour]
            local shade = shadesTable[math.random(#shadesTable)]

            if uniqueColours(colour, shades) then
                shades[colour] = shade
                table.insert(colours, colour)
                newColour = true
            end
        end
    end

    return shades, colours
end

function Board:generatePatterns()
    local patterns = {}
    local maxPattern = math.min(6, self.level)

    for i = 1, maxPattern do
        patterns[i] = i
    end

    return patterns
end

function Board:getColours()
    local shade = self.shades[self.colours[math.random(#self.colours)]]

    return shade
end

function Board:getPatterns()
    local pattern = self.patterns[math.random(#self.patterns)]

    return pattern
end

function Board:calculateMatches()
    local matches = {}

    local matchNum = 1

    for y = 1, 8 do
        local colourtoMatch = self.tiles[y][1].colour

        matchNum = 1

        for x = 2, 8 do
            if self.tiles[y][x].colour == colourtoMatch then
                matchNum = matchNum + 1
            else
                colourtoMatch = self.tiles[y][x].colour

                if matchNum >= 3 then
                    local match = {}

                    for x2 = x - 1, x - matchNum, -1 do
                        table.insert(match, self.tiles[y][x2])
                    end

                    table.insert(matches, match)

                    if matchNum >= 4 then
                        table.insert(self.shinyTiles, ShinyTile(x - matchNum + 1, y, 
                            self.tiles[y][x - 1].colour, self.tiles[y][x - 1].variety))
                    end
                end

                matchNum = 1

                if x >= 7 then break end
            end
        end

        if matchNum >= 3 then
            local match = {}

            for x = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)

            if matchNum >= 4 then
                table.insert(self.shinyTiles, ShinyTile(8 - matchNum + 1, y, 
                    colourtoMatch, self.tiles[y][8].variety))
            end
        end
    end
    
    for x = 1, 8 do
        local colourtoMatch = self.tiles[1][x].colour

        matchNum = 1

        for y = 2, 8 do
            if self.tiles[y][x].colour == colourtoMatch then
                matchNum = matchNum + 1
            else     
                colourtoMatch = self.tiles[y][x].colour

                if matchNum >= 3 then
                    local match = {}

                    for y2 = y - 1, y - matchNum, -1 do
                        table.insert(match, self.tiles[y2][x])
                    end

                    table.insert(matches, match)

                    if matchNum >= 4 then
                        table.insert(self.shinyTiles, ShinyTile(x, y - matchNum + 1,                            
                            self.tiles[y - 1][x].colour, self.tiles[y - 1][x].variety))
                    end
                end

                matchNum = 1

                if y >= 7 then break end
            end
        end

        if matchNum >= 3 then
            local match = {}

            for y = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)

            if matchNum >= 4 then
                table.insert(self.shinyTiles, ShinyTile(x, 8 - matchNum + 1,
                    colourtoMatch, self.tiles[8][x].variety))
            end
        end
    end

    self.matches = matches

    return #self.matches > 0 and self.matches or false
end

-- longer and less efficient version of checking
function Board:possibleSwap()
    -- horizontal pair or vertical pair
    local hpairs = {}
    local vpairs = {}

    -- triplets with empty middle
    local hmid = {}
    local vmid = {}
    local possibleSwap = false
    self.possibles = {}

    -- for horizontal pair
    for y = 1, 8 do
        local pairColour = self.tiles[y][1].colour

        for x = 2, 8 do
            local pairs = {}
            if self.tiles[y][x].colour == pairColour then
                pairs['left'] = self.tiles[y][x - 1]
                pairs['right'] = self.tiles[y][x]

                table.insert(hpairs, pairs)
            else
                pairColour = self.tiles[y][x].colour
            end
        end
    end

    -- for vertical pair
    for x = 1, 8 do
        local pairColour = self.tiles[1][x].colour

        for y = 2, 8 do
            local pairs = {}
            if self.tiles[y][x].colour == pairColour then
                pairs['up'] = self.tiles[y - 1][x]
                pairs['down'] = self.tiles[y][x]

                table.insert(vpairs, pairs)
            else
                pairColour = self.tiles[y][x].colour
            end
        end
    end

    -- for horizontal middle case
    for y = 1, 8 do
        for x = 1, 6 do
            local colourtoMatch = self.tiles[y][x].colour
            local mid = {}

            if self.tiles[y][x + 2].colour == colourtoMatch then
                mid['left'] = self.tiles[y][x]
                mid['right'] = self.tiles[y][x + 2]

                table.insert(hmid, mid)
            end
        end
    end

    -- for vertical middle case
    for x = 1, 8 do
        for y = 1, 6 do
            local colourtoMatch = self.tiles[y][x].colour
            local mid = {}

            if self.tiles[y + 2][x].colour == colourtoMatch then
                mid['up'] = self.tiles[y][x]
                mid['down'] = self.tiles[y + 2][x]

                table.insert(vmid, mid)
            end
            
            colourtoMatch = self.tiles[y + 1][x].colour
        end
    end
        
    -- check for 4 corners of the pairs:
    for k, pair in pairs(hpairs) do
        for pos, tile in pairs(pair) do
            if pos == 'left' then

                -- top left
                if tile.gridX > 1 and tile.gridY > 1 then
                    if self.tiles[tile.gridY - 1][tile.gridX - 1].colour == tile.colour then
                        local match = self.tiles[tile.gridY - 1][tile.gridX - 1]
                        makeGroup(self.possibles, pair, match)
                        return true
                    end
                end

                -- top right
                if tile.gridX < 7 and tile.gridY > 1 then
                    if self.tiles[tile.gridY - 1][tile.gridX + 2].colour == tile.colour then
                        local match = self.tiles[tile.gridY - 1][tile.gridX + 2]
                        makeGroup(self.possibles, pair, match)
                        return true
                    end
                end

                -- bottom left
                if tile.gridX > 1 and tile.gridY < 8 then
                    if self.tiles[tile.gridY + 1][tile.gridX - 1].colour == tile.colour then
                        local match = self.tiles[tile.gridY + 1][tile.gridX - 1]
                        makeGroup(self.possibles, pair, match)
                        return true
                    end
                end
                -- bottom right
                if tile.gridX < 7 and tile.gridY < 8 then
                    if self.tiles[tile.gridY + 1][tile.gridX + 2].colour == tile.colour then
                        local match = self.tiles[tile.gridY + 1][tile.gridX + 2]
                        makeGroup(self.possibles, pair, match)
                        return true
                    end
                end

                -- checks for 2 left blocks away
                if tile.gridX > 2 then
                    if self.tiles[tile.gridY][tile.gridX - 2].colour == tile.colour then
                        local match = self.tiles[tile.gridY][tile.gridX - 2]
                        makeGroup(self.possibles, pair, match)
                        return true
                    end
                end

                -- checks for 2 right blocks away
                if tile.gridX < 6 then
                    if self.tiles[tile.gridY][tile.gridX + 3].colour == tile.colour then
                        local match = self.tiles[tile.gridY][tile.gridX + 3]
                        makeGroup(self.possibles, pair, match)
                        return true
                    end
                end
            end
        end
    end

    for k, pair in pairs(vpairs) do
        for pos, tile in pairs(pair) do
            if pos == 'up'then

                -- top left
                if tile.gridX > 1 and tile.gridY > 1 then
                    if self.tiles[tile.gridY - 1][tile.gridX - 1].colour == tile.colour then
                        local match = self.tiles[tile.gridY - 1][tile.gridX - 1]
                        makeGroup(self.possibles, pair, match)
                        return true
                    end
                end

                -- top right
                if tile.gridX < 8 and tile.gridY > 1 then
                    if self.tiles[tile.gridY - 1][tile.gridX + 1].colour == tile.colour then
                        local match = self.tiles[tile.gridY - 1][tile.gridX + 1]
                        makeGroup(self.possibles, pair, match)
                        return true
                    end
                end

                -- bottom left
                if tile.gridX > 1 and tile.gridY < 7 then
                    if self.tiles[tile.gridY + 2][tile.gridX - 1].colour == tile.colour then
                        local match = self.tiles[tile.gridY + 2][tile.gridX - 1]
                        makeGroup(self.possibles, pair, match)
                        return true
                    end
                end

                -- bottom right
                if tile.gridX < 8 and tile.gridY < 7 then
                    if self.tiles[tile.gridY + 2][tile.gridX + 1].colour == tile.colour then
                        local match = self.tiles[tile.gridY + 2][tile.gridX + 1]
                        makeGroup(self.possibles, pair, match)
                        return true
                    end
                end

                -- checks for 2 blocks away
                if tile.gridY > 2 then
                    if self.tiles[tile.gridY - 2][tile.gridX].colour == tile.colour then
                        local match = self.tiles[tile.gridY - 2][tile.gridX]
                        makeGroup(self.possibles, pair, match)
                        return true
                    end
                end

                if tile.gridY < 6 then
                    if self.tiles[tile.gridY + 3][tile.gridX].colour == tile.colour then
                        local match = self.tiles[tile.gridY + 3][tile.gridX]
                        makeGroup(self.possibles, pair, match)
                        return true
                    end
                end
            end
        end
    end

    for k, pair in pairs(hmid) do
        for pos, tile in pairs(pair) do
            if pos == 'left' then
                if tile.gridY > 1 then
                    if self.tiles[tile.gridY - 1][tile.gridX + 1].colour == tile.colour then
                        local match = self.tiles[tile.gridY - 1][tile.gridX + 1]
                        makeGroup(self.possibles, pair, match)
                        return true
                    end
                end

                if tile.gridY < 8 then
                    if self.tiles[tile.gridY + 1][tile.gridX + 1].colour == tile.colour then
                        local match = self.tiles[tile.gridY + 1][tile.gridX + 1]
                        makeGroup(self.possibles, pair, match)
                        return true
                    end
                end
            end
        end
    end

    for k, pair in pairs(vmid) do
        for pos, tile in pairs(pair['up']) do
            if pos == 'up' then
                if tile.gridX > 1 then
                    if self.tiles[tile.gridY + 1][tile.gridX - 1].colour == tile.colour then
                        local match = self.tiles[tile.gridY + 1][tile.gridX - 1]
                        makeGroup(self.possibles, pair, match)
                        return true
                    end
                end

                if tile.gridX < 8 then
                    if self.tiles[tile.gridY + 1][tile.gridX + 1].colour == tile.colour then
                        local match = self.tiles[tile.gridY + 1][tile.gridX + 1]
                        makeGroup(self.possibles, pair, match)
                        return true
                    end
                end
            end
        end
    end

    return possibleSwap
end

function Board:shuffle()
    local tweens = {}

    for y = 1, 8 do
        for x = 1, 8 do
            tile = self.tiles[y][x]
            tweens[tile] = {x = (VIRTUAL_WIDTH - 160 - self.x), y = (VIRTUAL_HEIGHT/2 - 16 - self.y)}                
        end
    end

    Timer.tween(1, tweens)
    :finish(function() 
        tweens = {}
        self.reset = true

        self.tiles = {}
        self:initialiseTiles()

        for y = 1, 8 do
            for x = 1, 8 do
                tile = self.tiles[y][x]
                local destinationX, destinationY = tile.x, tile.y
                tile.x, tile.y = (VIRTUAL_WIDTH - 160 - self.x), (VIRTUAL_HEIGHT/2 - 16 - self.y)
                tweens[tile] = {x = destinationX, y = destinationY}
            end
        end

        Timer.after(1, function()
            self.reset = false
            Timer.tween(0.5, tweens)
            :finish(function()
                self.shuffleFinish = true
            end)
        end)
    end)
    return true
end

function Board:possibleSwap2()
    self.possibles = {}
    for row = 1, 8 do
        for col = 1, 8 do
            local currentTile = self.tiles[row][col]

            -- first swap the tiles, then check if there are matches, then swap back
            if col > 1 then
                local newTile = self.tiles[row][col - 1]
                self:swapTiles(currentTile, newTile)
                if self:checkMatches(currentTile, newTile) then
                    return true
                end
            end

            if col < 8 then
                local newTile = self.tiles[row][col + 1]
                self:swapTiles(currentTile, newTile)
                if self:checkMatches(currentTile, newTile) then
                    return true
                end
            end

            if row > 1 then
                local newTile = self.tiles[row - 1][col]
                self:swapTiles(currentTile, newTile)
                if self:checkMatches(currentTile, newTile) then
                    return true
                end
            end
            
            if row < 8 then
                local newTile = self.tiles[row + 1][col]
                self:swapTiles(currentTile, newTile)
                if self:checkMatches(currentTile, newTile) then
                    return true
                end
            end
        end
    end

    return false
end

-- function to support possibleSwap2()
function Board:swapTiles(currentTile, newTile)
    currentTile.gridX, newTile.gridX = newTile.gridX, currentTile.gridX
    currentTile.gridY, newTile.gridY = newTile.gridY, currentTile.gridY
    self.tiles[currentTile.gridY][currentTile.gridX] = currentTile
    self.tiles[newTile.gridY][newTile.gridX] = newTile
end

-- if there are matches then save it into possibles
function Board:checkMatches(currentTile, newTile)
    local matches = self:calculateMatches()

    if not matches then
        self:swapTiles(currentTile, newTile)
    else
        for k, match in pairs(matches) do
            table.insert(self.possibles, match)
        end
        
        self:swapTiles(currentTile, newTile)
        return true
    end
end

function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            if tile.shiny then
                tile.shineTimer:remove()
                for i = 1, 8 do
                    gSounds['line-clear']:play()
                    table.insert(self.removedTiles, self.tiles[tile.gridY][i])
                    self.tiles[tile.gridY][i] = nil
                end
            else
                table.insert(self.removedTiles, tile)
                self.tiles[tile.gridY][tile.gridX] = nil
            end
        end
    end

    -- for k, tile in pairs(self.removedTiles) do
    --     Timer.after(1, self.tiles[tile.gridY][tile.gridX] = nil
    -- end

    -- replace the removed 4 match with shiny tile
    for k, tile in pairs(self.shinyTiles) do
        gSounds['shiny-formed']:stop()
        gSounds['match']:stop()
        gSounds['shiny-formed']:play()
        self.tiles[tile.gridY][tile.gridX] = tile
    end

    self.shinyTiles = {}
    self.matches = nil
end

function Board:getFallingTiles()
    local tweens = {}

    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            local tile = self.tiles[y][x]

            if space then
                if tile then
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY
                    self.tiles[y][x] = nil
                    
                    tweens[tile] = {y = 32 * (tile.gridY - 1)}

                    space = false
                    y = spaceY

                    spaceY = 0
                end
            elseif tile == nil then
                space = true
                
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]
            
            if not tile then
                local tile = Tile(x, y, self:getColours(), self:getPatterns())
                tile.y = -32
                self.tiles[y][x] = tile

                tweens[tile] = {y = 32 * (tile.gridY - 1)}
            end
        end
    end

    return tweens
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
            self.tiles[y][x]:renderParticles(self.x, self.y)
        end
    end

    if self.reset then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(gTextures['shuffle'], VIRTUAL_WIDTH - 160, VIRTUAL_HEIGHT/2 + 16, 
            0, 0.5, 0.5, 225, 225)

        love.graphics.setColor(1, 1, 0, 1)
        love.graphics.setFont(gFonts['large'])
        love.graphics.print('SWAPPING', VIRTUAL_WIDTH - 240, VIRTUAL_HEIGHT/2 - 120)
    end
end

function Board:showPossibles()
    for k, group in pairs(self.possibles) do
        for k, tile in pairs(group) do
            love.graphics.setColor(0.5, 0, 0, 1)
            love.graphics.rectangle('line', tile.x + self.x, tile.y + self.y, 32, 32)
        end
    end
end