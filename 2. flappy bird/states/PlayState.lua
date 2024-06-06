PlayState = Class{__includes = BaseState}

PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288

BIRD_WIDTH = 38
BIRD_HEIGHT = 24

function PlayState:init()
    self.bird = Bird()
    self.pipePairs = {}
    self.timer = 0
    self.lastY = -PIPE_HEIGHT + math.random(80) + 20

    self.score = 0
    self.newPipe = true
    self.paused = false
end

-- retrieves previous datas before the game is paused
function PlayState:enter(params)
    if params ~= nil then
        paused = false
        self.bird = params.bird
        self.pipePairs = params.pipePairs
        self.timer = params.timer
        self.lastY = params.lastY
        self.score = params.score
        self.newPipe = params.newPipe
        self.paused = paused
    end
end

function PlayState:update(dt)
    -- change the game state to pause
    if love.keyboard.wasPressed('p') then
        self.paused = true
        sounds.pause:play()
        gStateMachine:change('pause', {
            bird = self.bird,
            pipePairs = self.pipePairs,
            timer = self.timer,
            lastY = self.lastY,
            score = self.score,
            newPipe = self.newPipe,
            paused = self.paused
        })
    end

    self.timer = self.timer + dt

    -- give random gap and time interval when spawning the pipes
    if self.newPipe then
        randomTime = getRandomTime()
        GAP_HEIGHT = getGapHeight()
        self.newPipe = false
    end

    if self.timer > randomTime then   
        local y = math.max(-PIPE_HEIGHT + 10, 
            math.min(self.lastY + math.random(-30, 30),  VIRTUAL_HEIGHT - PIPE_HEIGHT - GAP_HEIGHT))
        self.lastY = y

        table.insert(self.pipePairs, PipePair(y))
        self.timer = 0
        self.newPipe = true
    end

    self.bird:update(dt)

    for k, pair in pairs(self.pipePairs) do
        if not pair.scored then
            if self.bird.x > pair.x + PIPE_WIDTH then
                self.score = self.score + 1
                sounds.score:play()
                pair.scored = true
            end
        end

        pair:update(dt)

        for l, pipes in pairs(pair.pipes) do
            if self.bird:collide(pipes) then
                gStateMachine:change('score', self.score)
                sounds.hurt:play()
                sounds.explosion:play()
            end
        end

        if pair.remove then
            table.remove(self.pipePairs, k)
        end
    end

    if self.bird.y + BIRD_HEIGHT > VIRTUAL_HEIGHT - 15 then
        gStateMachine:change('score', self.score)
        sounds.hurt:play()
        sounds.explosion:play()
    end
end

function PlayState:render()
    for k, pipes in pairs(self.pipePairs) do
        pipes:render()
    end

    love.graphics.setFont(flappyFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 5, VIRTUAL_WIDTH, 'left')

    self.bird:render()
end

