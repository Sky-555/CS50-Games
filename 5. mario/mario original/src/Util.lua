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