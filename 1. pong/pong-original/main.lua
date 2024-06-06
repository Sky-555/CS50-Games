-- original version, used to learn from scratch

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

    love.window.setTitle('Pong')

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

    gameState = 'start'
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    if gameState == 'serve' then
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(150, 210)
        else
            ball.dx = -math.random(150, 210)
        end
    elseif gameState == 'play' then
        ball:update(dt)

        if ball:collide(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5
            if ball.dy < 0 then 
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds.paddle_hit:play()
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
        end

        if ball.x < -4 then
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

        if ball.y <= 0  then
            ball.y = 0
            ball.dy = -ball.dy
            sounds.wall_hit:play()
        end
        if ball.y >= Virtual_Height - 4 then
            ball.y = Virtual_Height - 4
            ball.dy = - ball.dy
            sounds.wall_hit:play()
        end
    end

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

    player1:update(dt)
    player2:update(dt)
end

function love.keypressed(key)
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

    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Hello Pong', 0, 10, Virtual_Width, 'center')
        love.graphics.printf('Press "Enter" to serve', 0, 20, Virtual_Width, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        
        if Player1_Score == 0 and Player2_Score == 0 then
            love.graphics.printf('Player ' .. tostring(servingPlayer) .. ' \'s serve ', 0, 10, Virtual_Width, 'center')
            love.graphics.printf('Press "Enter" to serve', 0, 20, Virtual_Width, 'center')
        else
            -- Using ternary operation to print who scored and who's going to serve

            love.graphics.printf('Player ' .. tostring(servingPlayer == 1 and 2 or 1) .. ' scored', 0, 10, Virtual_Width, 'center')
            love.graphics.printf('Player ' .. tostring(servingPlayer == 2 and 2 or 1) .. ' \'s serve ', 0, 20, Virtual_Width, 'center')
            love.graphics.printf('Press "Enter" to serve', 0, 30, Virtual_Width, 'center')
        end
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

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS:' .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
end