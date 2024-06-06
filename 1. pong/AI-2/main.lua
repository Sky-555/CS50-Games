-- Version update:
-- 1) implement formula to calculate the ball trajectory, and makes computer move there.
-- 2) Computer got nerfed and only reacts to the ball when it's their turn.
-- 3) Does not work if ball bounces more than once

push = require 'push'
Class = require 'class'
require 'Ball'
require 'Paddle'

Window_Width = 1280
Window_Height = 720

Virtual_Width = 432
Virtual_Height = 243

Paddle_Speed = 200

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('PongAI')

    push:setupScreen(Virtual_Width, Virtual_Height, Window_Width, Window_Height, {
        fullscreen = false,
        resizable = true,
        vsync = true,
        canvas = false
    })

    math.randomseed(os.time())

    -- Added Winning sound

    sounds = {
        ['paddle_hit'] = love.audio.newSource('Sounds/Paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/Wall_hit.wav', 'static'),
        ['win'] = love.audio.newSource('sounds/Winning.wav', 'static')
    }

    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    servingPlayer = math.random(1, 2)
    winningPlayer = 0

    Player1_Score = 0
    Player2_Score = 0

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(Virtual_Width - 15, Virtual_Height - 50, 5, 20)

    ball = Ball(Virtual_Width/2 - 2, Virtual_Height/2 - 2, 4, 4)

    targetY = Virtual_Height / 2 - 2

    -- Default player state to 'AI'
    playerState = 'AI'
    gameState = 'pick'
end

function love.resize(w, h)
    push:resize(w, h)
end

-- takes parameter from Ball:getParameters()
-- targetY is the place where the ball is supposed to hit, will move midpoint of paddle there
-- this formula applies the linear graph equation, using dy/dx and dx/dy and the line equation
-- y = mx + c and x = y/m + b 

-- calculate when the game begins
function serveCalculation(sy, vx, vy)
    local distance = Virtual_Width / 2 - 17
    local m = math.abs(vy / vx)
    if vy > 0 then
        targetY = Virtual_Height / 2 - 2 + distance* m
    elseif vy < 0 then
        targetY = Virtual_Height / 2 - 2 - distance * m
    else
        targetY = sy
    end
    return targetY
end

-- calculate when the ball collides with the paddle
-- wallX is the x-coordinate where ball collides with the wall
function playCalculation(sy ,vx ,vy)
    local m = math.abs(vy / vx)
    local leftX = 15
    local rightX = Virtual_Width - 19
    local paddleDistance = rightX - leftX
    local upY = sy
    local downY = Virtual_Height - 4

    -- check which direction is the ball heading
    -- comparing slope dy/dx to determine if the ball hits the vertical wall and rebound
    if vy < 0 then
        if m > upY / paddleDistance then 
            if vx < 0 then              -- North West
                wallX = rightX - upY / m
                targetY = (wallX - leftX) * m
            else                        -- North East
                wallX = leftX + upY / m
                targetY = (rightX - wallX) * m
            end
        else
            targetY = upY - paddleDistance * m -- if ball doesnt rebound
        end
    else
        if m > (downY - upY) / paddleDistance then 
            if vx < 0 then              -- South West
                wallX = rightX - (downY - upY) / m
                targetY = downY - (wallX - leftX) * m
            else                        -- South East
                wallX = leftX + (downY - upY) / m
                targetY = downY - (rightX - wallX) * m
            end
        else
            targetY = upY + paddleDistance * m -- if ball doesnt rebound
        end
    end
    return targetY
end

function love.update(dt)
    if gameState == 'serve' then
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(150, 210)
        else
            ball.dx = -math.random(150, 210)
        end
        sy, vx, vy = ball:getParameters()
        targetY = serveCalculation(sy, vx, vy)

        -- to toggle caluclation and movement
        served = true
        player1Turn = false
        player2Turn = false

    elseif gameState == 'play' then
        ball:update(dt)

        -- the following block is for AI side movement
        if playerState ~= 'manual' then          
            if served then
                if servingPlayer == 1 then
                    if playerState ~= '2' then
                        player2:move(targetY, dt)
                    end
                else
                    if playerState ~= '1' then
                        player1:move(targetY, dt)
                    end
                end
            end
        end
        if ball:collide(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5
            if ball.dy < 0 then 
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds.paddle_hit:play()
            served = false
            player1.dy = 0
            if playerState ~= '2' and playerState ~= 'manual' then
                sy, vx, vy = ball:getParameters()
                targetY = playCalculation(sy, vx, vy)
                player1Turn = false
                player2Turn = true
            end
        end
        if ball:collide(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4
            if ball.dy < 0 then 
                ball.dy = - math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds.paddle_hit:play()
            served = false
            player2.dy = 0
            if playerState ~= '1' and playerState ~= 'manual' then
                sy, vx, vy = ball:getParameters()
                targetY = playCalculation(sy, vx, vy)
                player2Turn = false
                player1Turn = true
            end
        end

        if player2Turn then 
            if playerState ~= '2' then
                player2:move(targetY, dt)
            end
            player1Turn = false
        end
        if player1Turn then
            if playerState ~= '1' then
                player1:move(targetY, dt)
            end
            player2Turn = false
        end

        if ball.x < 0 then
            servingPlayer = 1
            Player2_Score = Player2_Score + 1
            if Player2_Score == 10 then
                winningPlayer = 2
                gameState = 'done'
                sounds.win:play()
            else
                gameState = 'serve'
                ball:reset()
            end
            sounds.score:play()
        end
        if ball.x > Virtual_Width then
            servingPlayer = 2
            Player1_Score = Player1_Score + 1
            if Player1_Score == 10 then
                winningPlayer = 1
                gameState = 'done'
                sounds.win:play()
            else
                gameState = 'serve'
                ball:reset()
            end
            sounds.score:play()
        end
    end

    -- This part will let player only be able to control the side they chose
    player1:update(dt)
    player2:update(dt)

    if playerState == '1' then
        if love.keyboard.isDown('up') then
            player1.dy = -Paddle_Speed
        elseif love.keyboard.isDown('down') then
            player1.dy = Paddle_Speed
        else
            player1.dy = 0
        end
    elseif playerState == '2' then
        if love.keyboard.isDown('up') then
            player2.dy = -Paddle_Speed
        elseif love.keyboard.isDown('down') then
            player2.dy = Paddle_Speed
        else
            player2.dy = 0
        end       
    elseif playerState == "manual" then
        if love.keyboard.isDown('w') then
            player1.dy = -Paddle_Speed
        elseif love.keyboard.isDown('s') then
            player1.dy = Paddle_Speed
        else
            player1.dy = 0
        end

        if love.keyboard.isDown('up') then
            player2.dy = -Paddle_Speed
        elseif love.keyboard.isDown('down') then
            player2.dy = Paddle_Speed
        else
            player2.dy = 0 
        end
    end
end

function love.keypressed(key)
    if gameState == 'pick' then
        if key == '1' then
            playerState = '1'
        elseif key == '2' then
            playerState = '2'
        elseif key == 'space' then
            playerState = 'AI'
        elseif key == 'm' then
            playerState = 'manual'
        else
            playerState = nil
            gameState = 'pick'
        end
        if playerState ~= nil then
            gameState = 'start'
        end
    end

    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then   
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'
            ball:reset()
            Player1_Score = 0
            Player2_Score = 0
            
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

function love.draw()
    push:apply('start')

    love.graphics.clear(40/255, 45/255, 52/255, 1)

    if gameState == 'pick' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong', 0, 10, Virtual_Width, 'center')
        love.graphics.printf('Press 1 or 2 to choose a player', 0, 20, Virtual_Width, 'center')
        love.graphics.printf('Press "Spacebar" to watch computer plays', 0, 30, Virtual_Width, 'center')
        love.graphics.printf('Press M to play with yourself', 0, 40, Virtual_Width, 'center')
        displaySide()
    end

    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        if playerState == '1' then
            love.graphics.printf('You are now playing as Player 1' , 0, 10, Virtual_Width, 'center')
        elseif playerState == '2' then
            love.graphics.printf('You are now playing as Player 2', 0, 10, Virtual_Width, 'center')
        elseif playerState == 'manual' then
            love.graphics.printf('Have fun!', 0, 10, Virtual_Width, 'center')
        elseif playerState == 'AI' then
            love.graphics.printf('Enjoy watching it', 0, 10, Virtual_Width, 'center')
        end
        love.graphics.printf('Press "Enter" to begin', 0, 20, Virtual_Width, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        
        if Player1_Score == 0 and Player2_Score == 0 then
            love.graphics.printf('Player ' .. tostring(servingPlayer) .. ' \'s serve ', 0, 10, Virtual_Width, 'center')
            love.graphics.printf('Press "Enter" to serve', 0, 20, Virtual_Width, 'center')
        else
            -- Using ternary operation to print who scored and who's going to serve

            love.graphics.printf('Player ' .. tostring(servingPlayer == 2 and 1 or 2) .. ' scored', 0, 10, Virtual_Width, 'center')
            love.graphics.printf('Player ' .. tostring(servingPlayer == 2 and 2 or 1) .. ' \'s serve ', 0, 20, Virtual_Width, 'center')
            love.graphics.printf('Press "Enter" to serve', 0, 30, Virtual_Width, 'center')
        end
    elseif gameState == 'play' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Ball Speed: ' .. tostring(math.floor(math.abs(vx))), 0, 10, Virtual_Width, 'center')
    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 10, Virtual_Width, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press "Enter" to restart!', 0, 30, Virtual_Width, 'center')
    end

    ball:render()
    player1:render()
    player2:render()

    displayScore()

    displayFPS()

    push:apply('end')
end

function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(Player1_Score), Virtual_Width/2 - 50, Virtual_Height/3)
    love.graphics.print(tostring(Player2_Score), Virtual_Width/2 + 30, Virtual_Height/3)
end

function displaySide()
    love.graphics.setFont(largeFont)
    love.graphics.print('1', 30, 30)
    love.graphics.print('2', Virtual_Width - 40, Virtual_Height - 50)
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
end