LevelMaker = Class{}

function LevelMaker.createMap(level)
    local bricks = {}
    local numRows = math.random(1, 5)
    local numCols = math.random(7, 13)
    numCols = numCols % 2 == 0 and (numCols + 1) or numCols

    local highestTier = math.min(3, math.floor(level / 5))
    local highestColour = math.min(5, math.floor(level % 5 + 3))

    for y = 1, numRows do
        local skipPattern = math.random(2) == 1 and true or false
        local alternatePattern = math.random(2) == 1 and true or false

        local alternateColour1 = math.random(1, highestColour)
        local alternateColour2 = math.random(1, highestColour)
        local alternateTier1 = math.random(0, highestTier)
        local alternateTier2 = math.random(0, highestTier)

        local skipFlag = math.random(2) == 1 and true or false
        local alternateFlag = math.random(2) == 1 and true or false

        local solidColour = math.random(1, highestColour)
        local solidTier = math.random(0, highestTier)

        for x = 1, numCols do
            if skipPattern and skipFlag then
                skipFlag = not skipFlag
                goto continue
            else
                skipFlag = not skipFlag
            end

            b = Brick(
                (x - 1) * 32 + 8 + (13 - numCols) * 16,
                y * 16
            )

            if alternatePattern and alternateFlag then
                b.colour = alternateColour1
                b.tier = alternateTier1
                alternatePattern = not alternatePattern
            else
                b.colour = alternateColour2
                b.tier = alternateTier2
                alternatePattern = not alternatePattern
            end

            if not alternatePattern then
                b.colour = solidColour
                b.tier = solidTier
            end

            table.insert(bricks, b)

            ::continue::
        end
    end

    return bricks
end