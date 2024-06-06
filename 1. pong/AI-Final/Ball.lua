Ball = Class{}

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
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
    if self.y <= 0  then
        self.y = 0
        self.dy = -self.dy
        sounds.wall_hit:play()
    end
    if self.y >= Virtual_Height - 4 then
        self.y = Virtual_Height - 4
        self.dy = - self.dy
        sounds.wall_hit:play()
    end
end

function Ball:getParameters()
    return self.y, self.dx, self.dy
end

function Ball:reset()
    self.x = Virtual_Width/2 - 2
    self.y = Virtual_Height/2 - 2
end

function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end