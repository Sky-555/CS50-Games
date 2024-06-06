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

function Paddle:move(targetY, dt)
    local midpoint = self.y + self.height/2 - 2

    if midpoint ~= targetY then
        if midpoint < targetY then
            self.dy = Paddle_Speed
        elseif midpoint > targetY then
            self.dy = -Paddle_Speed
        end

        -- allow some small amount of uncertainties, prevent jiggling and makes the paddle sit still
        if math.abs(midpoint - targetY) > 2 then
            midpoint = midpoint + self.dy * dt
        else
            self.dy = 0
            midpoint = targetY
        end
    end
end