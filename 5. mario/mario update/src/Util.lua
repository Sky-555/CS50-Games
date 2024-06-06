function GenerateQuads(atlas, tilewidth, tileheight)
    local sheetwidth = atlas:getWidth() / tilewidth
    local sheetheight = atlas:getHeight() / tileheight

    local quads = {}
    local counter = 1

    for y = 0, sheetheight - 1 do
        for x = 0, sheetwidth - 1 do
            quads[counter] = love.graphics.newQuad(x * tilewidth, y * tileheight, 
                tilewidth, tileheight, atlas:getDimensions())
            
            counter = counter + 1
        end
    end

    return quads
end

function table.slice(tbl, first, last, step)
    local sliced = {}

    for i = first, last or #tbl, step or 1 do
        sliced[#sliced + 1] = tbl[i]
    end

    return sliced
end

function GenerateTileSets(quads, setsX, setsY, sizeX, sizeY)
    local tilesets = {}
    local tableCounter = 0
    local sheetWidth = setsX * sizeX
    local sheetHeight = setsY * sizeY

    -- for each tile set on the X and Y
    for tilesetY = 1, setsY do
        for tilesetX = 1, setsX do
            
            -- tileset table
            table.insert(tilesets, {})
            tableCounter = tableCounter + 1

            for y = sizeY * (tilesetY - 1) + 1, sizeY * (tilesetY - 1) + 1 + sizeY do
                for x = sizeX * (tilesetX - 1) + 1, sizeX * (tilesetX - 1) + 1 + sizeX do
                    table.insert(tilesets[tableCounter], quads[sheetWidth * (y - 1) + x])
                end
            end
        end
    end

    return tilesets
end

function cropQuads(quads, leftCrop, rightCrop)
    local cropped = {}

    for k, quad in pairs(quads) do
        local width = quad:getWidth()
        local height = quad:getHeight()
        table.insert(cropped, love.graphics.newQuad(leftCrop, 0, width - righCrop, height, quad:getDimensions()))
    end

    return cropped
end

function GeneratePoleSets(atlas, tilewidth, polewidth, poleheight)
    local sheetwidth = atlas:getWidth() / tilewidth

    local quads = {}
    local counter = 1

    for x = 0, 5 do
        quads[counter] = love.graphics.newQuad(4 + x * tilewidth, 0, polewidth, poleheight, atlas:getDimensions())
        counter = counter + 1
    end

    return quads
end

function GenerateFlagSets(atlas, width, height)
    local flagsets = {}
    local counter = 1

    local x = 96
    local y = 0

    for i = 1, 4 do
        for j = 1, 3 do
            flagsets[counter] = love.graphics.newQuad(x, y, width, height, atlas:getDimensions())
            x = x + 16
            counter = counter + 1
        end

        x = 96
        y = y + 16
    end

    return flagsets
end