Tile = Class{}

function Tile:init(x, y, colour, variety)
    self.gridX = x
    self.gridY = y
    
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    self.colour = colour
    self.variety = variety
    
    self.shiny = false

    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 10)

    self.psystem:setParticleLifetime(0.5, 1)
    self.psystem:setLinearAcceleration(-10, -10, 10, 10)
    self.psystem:setEmissionArea('normal', 10, 10, 0, true)
    self.psystem:setColors(1, 1, 0, 0.5)
end

function Tile:update(dt)
    self.psystem:update(dt)
end

function Tile:render(x, y)
    love.graphics.setColor(34/255, 32/255, 52/255, 1)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.colour][self.variety],
        self.x + x + 2, self.y + y + 2)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.colour][self.variety],
        self.x + x, self.y + y)
end

function Tile:renderParticles(x, y)
    love.graphics.draw(self.psystem, self.x + x + 16, self.y + y + 16)
end