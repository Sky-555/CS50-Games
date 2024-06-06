function generateTileQuads(atlas)
    local tiles = {}

    local x = 0
    local y = 0

    local counter = 1

    for i = 1, 2 do
        for row = 1, 9 do
            tiles[counter] = {}
            
            for col = 1, 6 do
                table.insert(tiles[counter], love.graphics.newQuad(x, y, 32, 32, atlas:getDimensions()))
                x = x + 32
            end

            counter = counter + 1
            y = y + 32
            x = x - 192
        end
        y = 0
        x = x + 192
    end

    return tiles
end

function uniqueColours(colour, tbl)
    for k, v in pairs(tbl) do
        if k == nil then
            return true
        elseif colour == k then 
            return false
        else
            goto continue
        end
        ::continue::
    end

    return true
end

function makeGroup(tbl, pair, match)
    local group = {}

    for pos, tile in pairs(pair) do
        table.insert(group, tile)
    end

    table.insert(group, match)

    table.insert(tbl, group)
end