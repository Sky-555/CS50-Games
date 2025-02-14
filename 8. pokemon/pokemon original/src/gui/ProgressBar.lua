ProgressBar = Class{}

function ProgressBar:init(def)
    self.x = def.x
    self.y = def.y
    
    self.width = def.width
    self.height = def.height
    
    self.color = def.color

    self.value = def.value
    self.max = def.max
end

function ProgressBar:setMax(max)
    self.max = max
end

function ProgressBar:setValue(value)
    self.value = value
end

function ProgressBar:update()

end

function ProgressBar:render()
    local renderWidth = (self.value / self.max) * self.width

    love.graphics.setColor(self.color.r, self.color.g, self.color.b, 1)
    
    if self.value > 0 then
        love.graphics.rectangle('fill', self.x, self.y, renderWidth, self.height, 3)
    end

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height, 3)
    love.graphics.setColor(1, 1, 1, 1)
end