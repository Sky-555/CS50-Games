Bird = Class{}

local GRAVITY = 800

function Bird:init()
    self.image = love.graphics.newImage('bird.png')
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    self.x = VIRTUAL_WIDTH / 2 - self.width / 2
    self.y = VIRTUAL_HEIGHT / 2 - self.height / 2
    self.dy = 0
end

function Bird:collide(pipe)
    if self.x + self.width - 2 >= pipe.x and self.x + 2 <= pipe.x + PIPE_WIDTH then
        if self.y + self.height -2 >= pipe.y and self.y + 2 <= pipe.y + PIPE_HEIGHT then
            return true
        end
    end
end

-- added a function so that the bird won't fly above the screen
-- changed the formula a bit so there's a small amount of time for player to react to gravity
function Bird:update(dt)
    self.dy = self.dy + GRAVITY * dt 
    self.y = math.max(0, self.y + self.dy * dt)

    -- to make sure the bird's velocity is not too negative and will fall down instantly
    if self.y == 0 then
        self.dy = 0
    end

    if love.keyboard.wasPressed('space') or love.mouse.wasPressed(1) then
        self.dy = - 280
        sounds.jump:play()
    end
end

function Bird:render()
    love.graphics.draw(self.image, self.x, self.y)
end