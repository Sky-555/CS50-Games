AlienLaunchMarker = Class{}

function AlienLaunchMarker:init(world)
    self.world = world

    self.baseX = 90
    self.baseY = VIRTUAL_HEIGHT - 100

    self.shiftedX = self.baseX
    self.shiftedY = self.baseY

    self.aiming = false
    self.launched = false
    self.separated = false
    self.collided = false

    self.aliens = {}
end

function AlienLaunchMarker:update(dt)
    
    -- perform everything here as long as we haven't launched yet
    if not self.launched then

        -- grab mouse coordinates
        local x, y = push:toGame(love.mouse.getPosition())
        
        -- if we click the mouse and haven't launched, show arrow preview
        if love.mouse.wasPressed(1) and not self.launched then
            self.aiming = true

        -- if we release the mouse, launch an Alien
        elseif love.mouse.wasReleased(1) and self.aiming then
            self.launched = true

            -- spawn new alien in the world, passing in user data of player
            table.insert(self.aliens, Alien(self.world, 'round', self.shiftedX, self.shiftedY, 'Player'))

            self.aliens[1].body:setLinearVelocity((self.baseX - self.shiftedX) * 10, (self.baseY - self.shiftedY) * 10)
            self.aliens[1].fixture:setRestitution(0.4)
            self.aliens[1].body:setAngularDamping(3)

            -- we're no longer aiming
            self.aiming = false

        -- re-render trajectory
        elseif self.aiming then
            
            self.shiftedX = math.min(self.baseX + 30, math.max(x, self.baseX - 30))
            self.shiftedY = math.min(self.baseY + 30, math.max(y, self.baseY - 30))
        end
    else
        if not self.separated then
            self.x, self.y = self.aliens[1].body:getPosition()
            self.preSeparateVelocityX, self.preSeparateVelocityY = self.aliens[1].body:getLinearVelocity()

            if love.keyboard.wasPressed('space') and not self.collided then                
                local topPlayer = Alien(self.world, 'round', self.x, self.y, 'Player')
                topPlayer.body:setLinearVelocity(self.preSeparateVelocityX, self.preSeparateVelocityY - 50)
                topPlayer.fixture:setRestitution(0.4)
                topPlayer.body:setAngularDamping(3)
                
                table.insert(self.aliens, topPlayer)

                local bottomPlayer = Alien(self.world, 'round', self.x, self.y, 'Player')
                bottomPlayer.body:setLinearVelocity(self.preSeparateVelocityX, self.preSeparateVelocityY + 50)
                bottomPlayer.fixture:setRestitution(0.4)
                bottomPlayer.body:setAngularDamping(3)

                table.insert(self.aliens, bottomPlayer)

                self.separated = true
            end
        end

        
    end
end

function AlienLaunchMarker:render()
    if not self.launched then
        
        -- render base alien, non physics based
        love.graphics.draw(gTextures['aliens'], gFrames['aliens'][9], 
            self.shiftedX - 17.5, self.shiftedY - 17.5)

        if self.aiming then
            
            -- render arrow if we're aiming, with transparency based on slingshot distance
            local impulseX = (self.baseX - self.shiftedX) * 10
            local impulseY = (self.baseY - self.shiftedY) * 10

            -- draw 18 circles simulating trajectory of estimated impulse
            local trajX, trajY = self.shiftedX, self.shiftedY
            local gravX, gravY = self.world:getGravity()

            -- http://www.iforce2d.net/b2dtut/projected-trajectory
            for i = 1, 90 do
                
                -- magenta color that starts off slightly transparent
                love.graphics.setColor(1, 80/255, 1, (1 / 12) * i)
                
                -- trajectory X and Y for this iteration of the simulation
                trajX = self.shiftedX + i * 1/60 * impulseX
                trajY = self.shiftedY + i * 1/60 * impulseY + 0.5 * (i * i + i) * gravY * 1/60 * 1/60

                -- render every fifth calculation as a circle
                if i % 5 == 0 then
                    love.graphics.circle('fill', trajX, trajY, 3)
                end
            end
        end
        
        love.graphics.setColor(1, 1, 1, 1)
    else
        for k, alien in pairs(self.aliens) do
            alien:render()
        end
    end
end