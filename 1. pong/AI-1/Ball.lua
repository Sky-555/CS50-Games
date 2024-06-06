Ball = Class{}

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0
end

function Ball:collide(Paddle)
    if self.x > Paddle.x + Paddle.width or Paddle.x > self.x + self.width then
        return false
    end
    if self.y > Paddle.y + Paddle.height or Paddle.y > self.y + self.height then
        return false
    end
    return true
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:reset()
    self.x = Virtual_Width/2 - 2
    self.y = Virtual_Height/2 - 2
    self.width = 4
    self.height = 4
    self.dx = math.random(2) == 1 and 150 or -150
    self.dy = math.random(-50, 50)

end

function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end