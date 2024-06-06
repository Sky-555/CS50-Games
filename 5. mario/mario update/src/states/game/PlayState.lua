PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
    self.camX = 0
    self.camY = 0
    self.levelNum = params.levelNum
    self.map = LevelMaker(self.levelNum)
    self.level = self.map:generate()
    self.tileMap = self.level.tileMap
    self.background = math.random(3)
    self.backgroundX = 0

    self.gravityOn = true
    self.gravityAmount = 6

    self.player = Player{
        x = self.tileMap:solidGround(), y = 0,
        width = 16, height = 20,
        texture = 'green-alien',
        stateMachine = StateMachine {
            ['idle'] = function() return PlayerIdleState(self.player) end,
            ['walking'] = function() return PlayerWalkingState(self.player) end,
            ['jump'] = function() return PlayerJumpingState(self.player, self.gravityAmount) end,
            ['falling'] = function() return PlayerFallingState(self.player, self.gravityAmount) end
        },
        map = self.tileMap,
        level = self.level,
        score = params.score or 0
    }

    self:spawnEnemies()
    
    self.player:changeState('falling')
end

function PlayState:update(dt)
    Timer.update(dt)

    self.level:clear()

    self.player:update(dt)
    self.level:update(dt)
    self:updateCamera()

    if self.player.x <= 0 then
        self.player.x = 0
    elseif self.player.x > TILE_SIZE * self.tileMap.width - self.player.width then
        self.player.x = TILE_SIZE * self.tileMap.width - self.player.width
    end
end

function PlayState:render()
    love.graphics.push()
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX), 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX),
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX + 256), 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX + 256),
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    
    love.graphics.translate(-math.floor(self.camX), -math.floor(self.camY))
    
    self.level:render()

    self.player:render()
    love.graphics.pop()
    
    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(tostring(self.player.score), 5, 5)
    love.graphics.printf('Level ' .. tostring(self.levelNum), -3, 5, VIRTUAL_WIDTH, 'right')

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(tostring(self.player.score), 4, 4)
    love.graphics.printf('Level ' .. tostring(self.levelNum), -4, 4, VIRTUAL_WIDTH, 'right')

    -- debugging
    
    -- local y = 50
    -- love.graphics.printf(math.floor(tostring(self.player.x / 16 + 1)), 0, 30, VIRTUAL_WIDTH, 'center')
    -- for k, lock in pairs(self.map.objects.locks) do
    --     love.graphics.printf(tostring(lock.x / 16 + 1), 0, y, VIRTUAL_WIDTH, 'center')
    --     y = y + 10
    -- end

    -- for k, block in pairs(self.map.objects.jumpBlocks) do
    --     if block.hasKey then
    --         love.graphics.printf(tostring(block.x / 16 + 1), 0, y + 10, VIRTUAL_WIDTH, 'center')
    --         y = y + 10
    --     end
    -- end
end

function PlayState:updateCamera()
    self.camX = math.max(0, math.min(
        TILE_SIZE * self.tileMap.width - VIRTUAL_WIDTH, self.player.x - (VIRTUAL_WIDTH / 2 - 8)
    ))

    self.backgroundX = math.floor(self.camX / 3) % 256
end

function PlayState:spawnEnemies()
    for x = 1, self.tileMap.width do
        local groundFound = false

        for y = 1, self.tileMap.height do
            if not groundFound then
                if self.tileMap.tiles[y][x].id == TILE_ID_GROUND then
                    groundFound = true

                    if math.random(20) == 1 then
                        local snail
                        snail = Snail{
                            texture = 'creatures',
                            x = (x - 1) * TILE_SIZE,
                            y = (y - 2) * TILE_SIZE + 2,
                            width = 16, height = 16,
                            stateMachine = StateMachine{
                                ['idle'] = function() return SnailIdleState(self.tileMap, self.player, snail) end,
                                ['moving'] = function() return SnailMovingState(self.tileMap, self.player, snail) end,
                                ['chasing'] = function() return SnailChasingState(self.tileMap, self.player, snail) end
                            }
                        }

                        snail:changeState('idle', {wait = math.random(5)})

                        table.insert(self.level.entities, snail)
                    end
                end
            end
        end
    end
end