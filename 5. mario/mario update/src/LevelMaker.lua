-- making each generations a function

LevelMaker = Class{}

function LevelMaker:init(levelNum)
    self.levelNum = levelNum

    -- adding 10 to 100 for each level, height remains constant
    self.width = 100 + 10 * (self.levelNum - 1)
    self.height = 10

    self.tileID = TILE_ID_GROUND

    self.topper = true
    self.tileset = math.random(20)
    self.topperset = math.random(20)
    self.keyLockColour = math.random(#KEYS_AND_LOCKS)

    self:generateTiles()

    self.map = TileMap(self.width, self.height)
    self.map.tiles = self.tiles
end

function LevelMaker:generate() return GameLevel(self.entities, self.objects, self.map) end

function LevelMaker:generateTiles()
    ::regenerate::
    self.tiles = {}
    self.entities = {}

    -- nested table in self.objects to identify objects quicker
    self.objects = {
        ['jumpBlocks'] = {}, 
        ['bushes'] = {}, 
        ['gems'] = {}, 
        ['keys'] = {}, 
        ['locks'] = {},
        ['pole'] = {},
        ['flag'] = {}
    }

    -- to store all the pillars and chasms
    self.pillarX = {}
    self.chasmX = {}

    for x = 1, self.height do
        table.insert(self.tiles, {})
    end

    for x = 1, self.width do
        self.tileID = TILE_ID_EMPTY

        self.blockHeight = 4

        for y = 1, 6 do
            table.insert(self.tiles[y], Tile(x, y, self.tileID, nil, self.tileset, self.topperset))
        end

        if math.random(7) == 1 then
            for y = 7, self.height do
                table.insert(self.tiles[y], Tile(x, y, self.tileID, nil, self.tileset, self.topperset))
            end

            table.insert(self.chasmX, x)
        else
            self.tileID = TILE_ID_GROUND

            for y = 7, self.height do
                table.insert(self.tiles[y], Tile(x, y, self.tileID, y == 7 and self.topper or nil, self.tileset, self.topperset))
            end

            if math.random(8) == 1 then
                self.blockHeight = 2
                table.insert(self.pillarX, x)

                if math.random(8) == 1 then
                    self:generateBushes(x, 4)
                end

                self.tiles[5][x] = Tile(x, 5, self.tileID, self.topper, self.tileset, self.topperset)
                self.tiles[6][x] = Tile(x, 6, self.tileID, nil, self.tileset, self.topperset)
                self.tiles[7][x].topper = nil

            elseif math.random(8) == 1 then
                self:generateBushes(x, 6)
            end

            if x <= self.width - 3 then
                if math.random(10) == 1 then
                    self:generateJumpBlocks(x, self.blockHeight)
                end    
            end        
        end
    end

    local jumpBlocks = self.objects.jumpBlocks

    -- if last block is not in last 20% of map, then remake the map
    -- if jumpBlocks are less than 5, remake map cause we need to choose the last 4 blocks to randomly assign key
    if jumpBlocks[#jumpBlocks].x < math.floor(self.width * 0.8 - 1) * TILE_SIZE or #jumpBlocks < 5 then
        goto regenerate
    end

    -- reinitialise blockHeight to 4
    self.blockHeight = 4

    -- assign key to randomly chosen last 4 blocks
    ::retry::
    local blockWithKey = jumpBlocks[math.random(#jumpBlocks - 3, #jumpBlocks)]

    if blockWithKey.x < math.floor(self.width * 0.8 - 1) * TILE_SIZE then
        goto retry
    else
        blockWithKey.hasKey = true
    end

    ::retry1::
    local lockX = math.random(math.floor(self.width * 0.9), self.width - 3)

    for k, chasm in pairs(self.chasmX) do
        if lockX == chasm then
            goto retry1
        end
    end

    for k, object in pairs(self.objects.jumpBlocks) do
        if (lockX - 1) * TILE_SIZE == object.x then
            goto retry1
        end
    end

    for k, x in pairs(self.pillarX) do
        if lockX == x then
            self.blockHeight = 2
        end
    end

    self:generateLocks(lockX, self.blockHeight)
end

function LevelMaker:generateBushes(x, y)
    table.insert(self.objects.bushes,
        GameObject{
            texture = 'bushes',
            x = (x - 1) * TILE_SIZE,
            y = (y - 1) * TILE_SIZE,
            width = 16, height = 16,
            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
            collidable = false
        }
    )
end

function LevelMaker:generateJumpBlocks(x, y)
    local jumpBlock = GameObject{
        texture = 'jump-blocks',
        x = (x - 1) * TILE_SIZE,
        y = (y - 1) * TILE_SIZE,
        width = 16, height = 16,
        frame = math.random(#JUMP_BLOCKS),
        collidable = true,
        hit = false,
        solid = true,

        onCollide = function(obj)
            local occupied = false

            if not obj.hit then

                -- if block has key assigned, dont spawn gems
                if not obj.hasKey then
                    self:generateGems(x, y)
                else
                    self:generateKeys(x, y)
                end

                obj.hit = true
            end
            gSounds['empty-block']:play()
        end
    }

    table.insert(self.objects.jumpBlocks, jumpBlock)
end

function LevelMaker:generateGems(x, y)
    if math.random(5) == 1 then
        local gem = GameObject {
            texture = 'gems',
            x = (x - 1) * TILE_SIZE,
            y = (y - 1) * TILE_SIZE - 4,
            width = 16, height = 16,
            frame = math.random(#GEMS),
            collidable = true,
            consumable = true,
            solid = false,

            onConsume = function(player)
                gSounds['pickup']:stop()
                gSounds['pickup']:play()
                player.score = player.score + 100
            end
        }
        Timer.tween(0.1, {
            [gem] = {y = (y - 2) * TILE_SIZE}
        })

        gSounds['powerup-reveal']:stop()
        gSounds['powerup-reveal']:play()
        table.insert(self.objects.gems, gem)
    end
end

function LevelMaker:generateKeys(x, y)
    local key = GameObject{
        texture = 'keys',
        x = (x - 1) * TILE_SIZE,
        y = (y - 1) * TILE_SIZE - 4,
        width = 16, height = 16,
        frame = self.keyLockColour,
        collidable = true,
        consumable = true,
        solid = false,

        onConsume = function(player)
            gSounds['pickup']:stop()
            gSounds['pickup']:play()
            self.objects.locks[1].unlockable = true
        end
    }

    Timer.tween(0.1, {
        [key] = {y = (y - 2) * TILE_SIZE}
    })
    gSounds['powerup-reveal']:stop()
    gSounds['powerup-reveal']:play()

    table.insert(self.objects.keys, key)
end

function LevelMaker:generateLocks(x, y)
    local lock = GameObject{
        texture = 'locks',
        x = (x - 1) * TILE_SIZE,
        y = (y - 1) * TILE_SIZE,
        width = 16, height = 16,
        frame = self.keyLockColour,
        collidable = true,
        hit = false,
        solid = true,

        onCollide = function(obj)
            if obj.unlockable then
                gSounds['unlock']:play()
                self:generateFlagPole()
                table.remove(self.objects.locks, 1)
            else
                gSounds['empty-block']:play()
            end
        end
    }
    lock.unlockable = false

    table.insert(self.objects.locks, lock)
end

function LevelMaker:generateFlagPole()
    -- flag pole

    local x = self.width
    local y = 4

    -- if flag pole is on chasm, retry till it's on a land.
    ::retry2::
    x = x - 1

    for k, chasm in pairs(self.chasmX) do
        if x == chasm then
            goto retry2
        end
    end
    
    for k, X in pairs(self.pillarX) do
        if x == X then
            y = 2
        end
    end

    table.insert(self.objects.pole, 
        GameObject{
            texture = 'poles',
            x = (x - 1) * TILE_SIZE + 4,
            y = (y - 1) * TILE_SIZE,
            width = 16, height = 48,
            frame = math.random(6),
            collidable = true,
            hit = false,
            solid = false,

            onCollide = function(player)
                gSounds['music']:stop()
                local length = gSounds['win']:getDuration()
                gSounds['win']:play()

                gStateMachine:change('victory', {
                    levelNum = self.levelNum,
                    score = player.score
                })
            end
        }
    )

    -- spawn 3 flags, just to be fancy :D
    for i = 1, 3 do
        local colour = math.random(4)

        table.insert(self.objects.flag, 
            GameObject{
                texture = 'flags',
                x = (x - 1) * TILE_SIZE + 8,
                y = (y - 1) * TILE_SIZE,
                width = 16, height = 16,
                frame = 3 * colour - 2,
                collidable = false,
            }
        )

        y = y + 1
    end
end