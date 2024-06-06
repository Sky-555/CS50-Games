Paddle = Class{}

function Paddle:init(skin)
    self.size = 2

    self.width = self.size * 32
    self.height = 16

    self.x = VIRTUAL_WIDTH / 2 - 32
    self.y = VIRTUAL_HEIGHT - 32

    self.dx = 0
    self.skin = skin
end

function Paddle:update(dt)
    self.width = self.size * 32

    if love.keyboard.isDown('left') then
        self.dx = -PADDLE_SPEED
        self.x = math.max(0, self.x + self.dx * dt)
    elseif love.keyboard.isDown('right') then
        self.dx = PADDLE_SPEED
        self.x = math.min(VIRTUAL_WIDTH - self.width, self.x + self.dx * dt)
    else
        self.dx = 0
    end
end

function Paddle:render()
    love.graphics.draw(gTexture['main'], gFrames['paddles'][self.size + 4 * (self.skin - 1)], self.x, self.y)
end