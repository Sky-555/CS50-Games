function generateQuads(atlas, tilewidth, tileheight)
    local sheetWidth = atlas:getWidth() / tilewidth
    local sheetHeight = atlas:getHeight() / tileheight

    local sheetCounter = 1
    local spriteSheet = {}

    for y = 0, sheetHeight - 1 do
        for x = 0, sheetWidth - 1 do
            spriteSheet[sheetCounter] = love.graphics.newQuad(x * tilewidth, y * tileheight, 
                tilewidth, tileheight, atlas:getDimensions())
            sheetCounter = sheetCounter + 1
        end
    end

    return spriteSheet
end

function table.slice(tbl, first, last, step)
    local sliced = {}

    for i = first or 1, last or #tbl, step or 1 do
        sliced[#sliced + 1] = tbl[i]
    end

    return sliced
end


function generateQuadBricks(atlas)
    return table.slice(generateQuads(atlas, 32, 16), 1, 24)
end

function generateQuadPaddles(atlas)
    local x = 0
    local y = 64

    local quads = {}
    local counter = 1

    for i = 0, 3 do
        quads[counter] = love.graphics.newQuad(x, y, 32, 16, atlas:getDimensions())
        counter = counter + 1

        quads[counter] = love.graphics.newQuad(x + 32, y, 64, 16, atlas:getDimensions())
        counter = counter + 1
        
        quads[counter] = love.graphics.newQuad(x + 96, y, 96, 16, atlas:getDimensions())
        counter = counter + 1

        quads[counter] = love.graphics.newQuad(x, y + 16, 128, 16, atlas:getDimensions())
        counter = counter + 1

        x = 0
        y = y + 32
    end

    return quads
end

function generateQuadBalls(atlas)
    local x = 96
    local y = 48

    local quads = {}
    local counter = 1

    for i = 0, 3 do
        quads[counter] = love.graphics.newQuad(x, y, 8, 8, atlas:getDimensions())
        x = x + 8
        counter = counter + 1
    end
    
    x = 96
    y = 56

    for i = 0, 2 do
        quads[counter] = love.graphics.newQuad(x, y, 8, 8, atlas:getDimensions())
        x = x + 8
        counter = counter + 1
    end

    return quads
end

function generateQuadPowerups(atlas)
    local x = 128
    local y = 192

    local quads = {}
    local counter = 1

    for i = 0, 1 do
        quads[counter] = love.graphics.newQuad(x, y, 16, 16, atlas:getDimensions())
        counter = counter + 1
        x = x + 16
    end

    return quads
end

function table.index(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return k
        end
    end
end

function getCurrentScore(score) return score end

function getRandomTime() return math.random() + math.random(3, 5) end

