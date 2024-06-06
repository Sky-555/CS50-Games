Paddle = Class{}

function Paddle:init(x, y, width, height, dy)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = dy or 0
end

function Paddle:update(dt)
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    else 
        self.y = math.min(Virtual_Height - self.height, self.y + self.dy * dt)
    end
end

function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

function Paddle:autodetect(Ball, dt)
    local midpoint = self.y + self.height / 2
    if Ball.dy < 0 then
        if midpoint >= Ball.y then
            self.dy = -Paddle_Speed
            midpoint = math.min(midpoint + self.dy * dt, Ball.y + Ball.dy * dt)
        else    
            self.dy = Paddle_Speed
            midpoint = math.min(midpoint + self.dy *dt, Ball.y + Ball.dy * dt)
        end
    end
    if Ball.dy > 0 then
        if midpoint >= Ball.y then
            self.dy = -Paddle_Speed
            midpoint = math.min(midpoint + self.dy * dt, Ball.y + Ball.dy * dt)
        else
            self.dy = Paddle_Speed
            midpoint = math.min(midpoint + self.dy *dt, Ball.y + Ball.dy * dt)
        end
    end
end
