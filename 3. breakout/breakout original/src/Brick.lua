Brick = Class {}

paletteColours = {
    -- blue
    [1] = {
        ['r'] = 99 / 255,
        ['g'] = 155 / 255,
        ['b'] = 1
    },
    -- green
    [2] = {
        ['r'] = 106 / 255,
        ['g'] = 190 / 255,
        ['b'] = 47 / 255
    },
    -- red
    [3] = {
        ['r'] = 217 / 255,
        ['g'] = 87 / 255,
        ['b'] = 99 / 255
    },
    -- purple
    [4] = {
        ['r'] = 215 / 255,
        ['g'] = 123 / 255,
        ['b'] = 186 / 255
    },
    -- gold
    [5] = {
        ['r'] = 251 / 255,
        ['g'] = 242 / 255,
        ['b'] = 54 / 255
    }
}

function Brick:init(x, y)
    self.tier = 0
    self.colour = 1

    self.x = x
    self.y = y
    self.width = 32
    self.height = 16
    self.inPlay = true

    self.psystem = love.graphics.newParticleSystem(gTexture['particle'], 64)

    self.psystem:setParticleLifetime(0.5, 1)
    self.psystem:setLinearAcceleration(-15, 0, 15, 80)
    self.psystem:setAreaSpread('normal', 10, 10)
end

function Brick:hit()
    self.psystem:setColors(
        paletteColours[self.colour].r,
        paletteColours[self.colour].g,
        paletteColours[self.colour].b,
        55 * (self.tier + 1) / 255,
        paletteColours[self.colour].r,
        paletteColours[self.colour].g,
        paletteColours[self.colour].b,
        0
    )
    self.psystem:emit(64)


    gSounds['brick-hit-2']:stop()
    gSounds['brick-hit-2']:play()

    if self.tier > 0 then
        if self.colour > 1 then
            self.colour = self.colour - 1
        else
            self.tier = self.tier -1
            self.colour = 5
        end
    else
        if self.colour > 1 then
            self.colour = self.colour - 1
        else
            self.inPlay = false
        end
    end

    if not self.inPlay then
        gSounds['brick-hit-1']:stop()
        gSounds['brick-hit-1']:play()
    end
end

function Brick:update(dt)
    self.psystem:update(dt)
end

function Brick:render()
    if self.inPlay then
        love.graphics.draw(gTexture['main'], gFrames['bricks'][1 + self.tier + 4 * (self.colour - 1)], 
            self.x, self.y)
    end
end

function Brick:renderParticles()
    love.graphics.draw(self.psystem, self.x + 16, self.y + 8)
end