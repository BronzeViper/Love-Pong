push = require 'push'
Class = require 'class'
require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
	love.graphics.setDefaultFilter('nearest', 'nearest')
	math.randomseed(os.time())
	smallFont = love.graphics.newFont('font.ttf', 8)
	scoreFont = love.graphics.newFont('font.ttf', 32)
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT,{
		fullscreeen = false,
		resizable = true,
		vsync = true,
	})
	sounds = {
		['paddle_hit'] = love.audio.newSource('Sounds/paddle_hit.wav', 'static'),
		['score'] = love.audio.newSource('Sounds/score.wav', 'static'),
		['wall_hit'] = love.audio.newSource('Sounds/wall_hit.wav', 'static')
	}
	player1 = Paddle(10, 30, 5, 20)
	player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

	ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
	drag = 0
	servingPlayer = math.random(1, 2)

	gameState = 'start'
end

function love.resize(w, h)
	push:resize(w,h)
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()    
	elseif key == 'enter' or key == 'return' then
		if gameState == 'start' then
			gameState = 'play'
			drag = math.random(-5, 25)
		elseif gameState == 'serve' then
			gameState = 'play'
		else
			gameState = 'start'
			drag = math.random(-5, 25)
			ball:reset()
			player1.score = 0
			player2.score = 0
		end
	end
end
function love.update(dt)
	--Serve state
	if gameState == 'serve' then
		ball.dy = math.random(-50, 50)
		if servingPlayer == 1 then
			ball.dx = math.random(140, 200)
		else
			ball.dx = -math.random(140, 200)
		end
	end
	if gameState == 'play' then
		--Collision with paddle
		if ball:collides(player1) then
			ball.dx = -ball.dx * 1.03
			ball.x = player1.x + 5
			if ball.dy < 0 then
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end
			sounds['paddle_hit']:play()
		end
		if ball:collides(player2) then
			ball.dx = -ball.dx * 1.03
			ball.x = ball.x - 4
			if ball.dy < 0 then
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end
			sounds['paddle_hit']:play()
		end
		--Detect upper and lower boundary collision
		if ball.y <= 0 then
			ball.y = 0
			ball.dy = -ball.dy 
			sounds['wall_hit']:play()
		end
		if ball.y >= VIRTUAL_HEIGHT - 4 then
			ball.y = VIRTUAL_HEIGHT - 4
			ball.dy = -ball.dy	
			sounds['wall_hit']:play()
		end
		ball:update(dt)
	end
	--Updating Score
	if ball.x < 0 then
		servingPlayer = 1
		player2.score = player2.score + 1
		sounds['score']:play()
		ball:reset()
		if player2.score == 10 then
			winningPlayer = 2
			gameState = 'done'
		else
			gameState = 'serve'
		end
	end

	if ball.x > VIRTUAL_WIDTH then
		servingPlayer = 2
		player1.score = player1.score + 1
		sounds['score']:play()
		ball:reset()
		if player1.score == 10 then
			winningPlayer = 1
			gameState = 'done'
		else
			gameState = 'serve'
		end
	end

	--Player 1 Movement
	if love.keyboard.isScancodeDown('w') then
		player1.dy = PADDLE_SPEED * -1
	elseif love.keyboard.isScancodeDown('s') then
		player1.dy = PADDLE_SPEED
	else
		player1.dy = 0
	end
	--Player 2 Movement
	if love.keyboard.isDown('up') then
		player2.dy = PADDLE_SPEED * -1
	elseif love.keyboard.isDown('down') then
		player2.dy = PADDLE_SPEED
	else
		player2.dy = 0
	end
	player1:update(dt)
	player2:update(dt)
end

function love.draw()
	push:apply('start')
	--love.graphics.clear(40, 45, 52, 255)
	love.graphics.setBackgroundColor(100, 255, 0)
	love.graphics.setFont(smallFont)
	if gameState == 'start' then
		love.graphics.printf("Pong", 0, 15, VIRTUAL_WIDTH, 'center')
		love.graphics.printf("Press Enter to Play!", 0, 22, VIRTUAL_WIDTH, 'center')
	elseif gameState == 'serve' then
		love.graphics.printf("Player "..tostring(servingPlayer).."'s Serve", 0, 15, VIRTUAL_WIDTH, 'center')
		love.graphics.printf("Press Enter to Serve!", 0, 22, VIRTUAL_WIDTH, 'center')
	elseif gameState == 'done' then
		love.graphics.printf("Player "..tostring(winningPlayer).." is the Winner", 0, 15, VIRTUAL_WIDTH, 'center')
		love.graphics.printf("Press Enter to Play Again or Press Escape to Quit", 0, 22, VIRTUAL_WIDTH, 'center')	
	end
	love.graphics.setFont(scoreFont)
	love.graphics.print(tostring(player1.score), VIRTUAL_WIDTH / 2 - 67, VIRTUAL_HEIGHT / 5 - 20)
	love.graphics.print(tostring(player2.score), VIRTUAL_WIDTH / 2 + 50, VIRTUAL_HEIGHT / 5 - 20)
	love.graphics.setColor(0, 0, 255, 100)
	--First Paddle (Left)
	player1:render()
	--Second Paddle (Right)
	player2:render()
	--Ball
	love.graphics.setColor(255, 255, 0, 100)
	ball:render()
	displayFPS()
	push:apply('end')
end

function displayFPS()
	love.graphics.setFont(smallFont)
	love.graphics.setColor(0, 255, 255, 255)
	love.graphics.print('FPS:' .. tostring(love.timer.getFPS()), 10, 10)
end