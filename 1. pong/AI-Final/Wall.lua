-- Calculation formula moved here

Wall = Class{}

function Wall:init()
    self.width = Virtual_Width
    self.height = Virtual_Height
    self.x = 0
    self.y = 0
    self.bounce = 0
    leftX = 15
    rightX = self.width - 19
    paddleDistance = self.width - 34
    downY = self.height - 4
end

function Wall:numberBounce(sy, vx, vy)
    local m = math.abs(vy/vx)
    local loopFinish = true
    if vy > 0 then
        for n = 1, 0, -1 do
            if (downY - sy)/m + n*downY/m < paddleDistance then
                self.bounce = n + 1
                loopFinish = false
                break
            end
        end
        if loopFinish then
            self.bounce = 0
        end
    else
        for n = 1, 0, -1 do
            if sy/m + n*downY/m < paddleDistance then
                self.bounce = n + 1
                loopFinish = false
                break
            end
        end
        if loopFinish then
            self.bounce = 0
        end
    end
    return self.bounce
end

-- calculate when the ball collides with the paddle
-- wall.x is the x-coordinate where ball collides with the wall
function Wall:calculation(sy, vx, vy)
    local n = self:numberBounce(sy, vx, vy)
    local m = math.abs(vy / vx)
    -- check which direction is the ball heading
    -- comparing slope dy/dx to determine if the ball hits the vertical wall and rebound
    if vy < 0 then
        if m > sy / paddleDistance then 
            if vx < 0 then              -- North West
                self.x = rightX - sy / m
                if n == 1 then
                    self.y = (self.x - leftX) * m 
                else
                    self.x = self.x - downY / m
                    self.y = downY - (self.x - leftX) * m 
                end
            else                        -- North East
                self.x = leftX + sy / m
                if n == 1 then 
                    self.y = (rightX - self.x) * m
                else
                    self.x = self.x + downY / m
                    self.y = downY - (rightX - self.x) * m
                end
            end
        else
            self.y = sy - paddleDistance * m -- if ball doesnt rebound
        end
    else
        if m > (downY - sy) / paddleDistance then 
            if vx < 0 then              -- South West
                self.x = rightX - (downY - sy) / m
                if n == 1 then 
                    self.y = downY - (self.x - leftX) * m
                else
                    self.x = self.x - downY / m
                    self.y = (self.x - leftX) * m
                end
            else                        -- South East
                self.x = leftX + (downY - sy) / m
                if n == 1 then
                    self.y = downY - (rightX - self.x) * m
                else 
                    self.x = self.x + downY / m
                    self.y = (rightX - self.x) * m
                end
            end
        else
            self.y = sy + paddleDistance * m -- if ball doesnt rebound
        end
    end
    return self.y
end