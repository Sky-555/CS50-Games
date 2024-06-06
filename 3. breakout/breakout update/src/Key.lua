Key = Class{__includes = Powerup}

function Key:effects(bricks)
    gSounds['powerup']:play()
    
    for _, brick in pairs(bricks) do
        if brick.locked then
            -- downgrade the locked bricks to grey bricks
            brick.tier = 0
            brick.locked = false
            brick.unlocked = true
        end
    end
end

function Key:render()
    love.graphics.draw(gTexture['main'], gFrames['powerups'][2], self.x, self.y)
end