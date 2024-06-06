ShinyTile = Class{__includes = Tile}

function ShinyTile:init(x, y, colour, variety)
    self.gridX = x
    self.gridY = y
    
    self.x = (self.gridX - 1 ) * 32
    self.y = (self.gridY - 1 ) * 32

    self.colour = colour
    self.variety = variety

    self.revert = false
    self.revertTimer = Timer.every(1, function() self.revert = not self.revert end)

    self.transitionAlpha = 1
    self.shiny = true
end

function ShinyTile:render(x, y)
    love.graphics.setColor(34/255, 32/255, 52/255, 1)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.colour][self.variety],
        self.x + x + 2, self.y + y + 2)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.colour][self.variety],
        self.x + x, self.y + y)
        
    if self.revert then
        Timer.tween(1, {[self] = {transitionAlpha = 1}})
    else
        Timer.tween(1, {[self] = {transitionAlpha = 0}})
    end

    love.graphics.setColor(1, 1, 1, self.transitionAlpha)
    love.graphics.draw(gTextures['shiny'], self.x + x + 7, self.y + y - 5 , 0, 0.04, 0.04)
end