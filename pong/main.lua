WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200
Class = require 'class'
push = require 'push'

require "Ball"
require "Paddle"

function love.load()
  math.randomseed(os.time())
  love.graphics.setDefaultFilter('nearest','nearest')
  smallFont = love.graphics.newFont('GothicPixels.ttf',20)
  scoreFont = love.graphics.newFont('GothicPixels.ttf',20)

  player1_score = 0
  player2_score = 0

  player1Y = 30
  player2Y = VIRTUAL_HEIGHT-40

  love.window.setTitle("Pong")

sounds ={
  ['paddle_hit'] = love.audio.newSource('paddle_sound.wav','static'),
  ['side_hit'] = love.audio.newSource('wall_hit.wav','static'),
  ['score'] = love.audio.newSource('score_sound.wav','static'),
  ['sound_of_victory'] = love.audio.newSource('victory_sound.wav','static')
}


  gameState = 'start'

  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH,WINDOW_HEIGHT, {
  fullscreen = false,
  vsync = true,
  resizable = true
})
  servingPlayer = math.random(2) == 1 and 1 or 2
  winningPlayer = 0
  paddle1 = Paddle(5,20,5,20)
  paddle2 = Paddle(VIRTUAL_WIDTH-10,VIRTUAL_HEIGHT-30,5,20)
  ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 5, 5)

  if servingPlayer == 1 then
    ball.dx = 150
  else
    ball.dx = -150
  end
  function love.resize(w,h)
    push:resize(w,h)
end
function love.update(dt)
  if gameState == 'play' then
    if ball.x <= 0 then
      player2_score = player2_score + 1
      servingPlayer = 1
      sounds['score']:play()
      ball:reset()
      ball.dx = 150
      if player2_score >= 2 then
        gameState = 'victory'
        winningPlayer = 2
        player1_score = 0
        player2_score = 0
        sounds['sound_of_victory']:play()
      else
        gameState = 'serve'
      end
    end
    if ball.x >= VIRTUAL_WIDTH - 5 then
      player1_score = player1_score + 1
      servingPlayer = 2
      ball:reset()
      ball.dx = -150
      sounds['score']:play()
      if player1_score >= 2 then
        gameState = 'victory'
        winningPlayer = 1
        player1_score = 0
        player2_score = 0
        sounds['sound_of_victory']:play()
      else
        gameState = 'serve'
      end
    end

    paddle1:update(dt)
    paddle2:update(dt)

    if ball:collides(paddle1) then
      ball.dx = -ball.dx * 1.03
      ball.x = paddle1.x + 5

      sounds['paddle_hit']:play()

      if ball.dy < 0 then
        ball.dy = -math.random(10,150)
      else
        ball.dy = math.random(10,150)
      end
    end

    if ball:collides(paddle2) then
      ball.dx = -ball.dx * 1.03
      ball.x = paddle2.x - 5

      sounds['paddle_hit']:play()

      if ball.dy < 0 then
        ball.dy = -math.random(10,150)
      else
        ball.dy = math.random(10,150)
      end
    end

    if ball.y <= 0 then
      ball.dy = -ball.dy
      ball.y = 0

      sounds['side_hit']:play()
    end

    if ball.y >= VIRTUAL_HEIGHT - 5 then
      ball.dy = -ball.dy
      ball.y = VIRTUAL_HEIGHT - 5

      sounds['side_hit']:play()
    end


    if love.keyboard.isDown('w') then
      paddle1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
      paddle1.dy = PADDLE_SPEED
    else
      paddle1.dy = 0
    end

    if love.keyboard.isDown('up') then
      paddle2.dy = -PADDLE_SPEED

    elseif love.keyboard.isDown('down') then
      paddle2.dy = PADDLE_SPEED
    else
      paddle2.dy = 0

    end

    if gameState == 'play' then
      ball:update(dt)
    end
  end
end


function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  elseif key == 'enter' or key == 'return' then
    if gameState == 'start' then
      gameState = 'serve'
    elseif gameState == 'victory' then
      gameState = 'start'
    elseif gameState == 'serve' then
      gameState = 'play'

    end
  end
end


function love.draw()
     push:apply('start')
     love.graphics.clear(40/255, 70/255, 255/255, 150/255)

     love.graphics.setFont(smallFont)
     if gameState == 'start' then
       love.graphics.printf("Welcome to Pong!", 0, 20, VIRTUAL_WIDTH, 'center')
       love.graphics.printf("Press Enter to Play!", 0, 32 , VIRTUAL_WIDTH, 'center')
     elseif gameState == 'serve' then
       love.graphics.printf('Player ' .. tostring(servingPlayer).. "'s serve",0,32,VIRTUAL_WIDTH, 'center')
       love.graphics.printf("Press Enter to Serve!", 0, 62 , VIRTUAL_WIDTH, 'center')
     elseif gameState == 'victory' then
       love.graphics.printf('Player ' .. tostring(winningPlayer) .. " wins!",0,10,VIRTUAL_WIDTH,'center')
       love.graphics.printf('Press Enter to serve!', 0, 42, VIRTUAL_WIDTH, 'center')
     elseif gameState == 'play' then
        love.graphics.setFont(scoreFont)
        love.graphics.print(player1_score,VIRTUAL_WIDTH /2 -50, VIRTUAL_HEIGHT/3)
        love.graphics.print(player2_score,VIRTUAL_WIDTH /2 +50, VIRTUAL_HEIGHT/3)
      end

     paddle1:render()
     paddle2:render()
     ball:render()

     displayFPS()

     push:apply('end')
end
function displayFPS()
  love.graphics.setColor(0,1,0,1)
  love.graphics.setFont(smallFont)
  love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()),40,20)
  love.graphics.setColor(1,1,1,1)
end
