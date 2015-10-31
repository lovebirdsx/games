require('ani')

local img
local r = 0
local bomb_ani
local lightning_ani
local bomb_img

function love.load()
	img = love.graphics.newImage('arrow2.png')
	bomb_img = love.graphics.newImage('bomb_ani.png')
	bomb_ani = ani.create('bomb_ani.png', 8, 6, 50)
	lightning_ani = ani.create('lightning_ani.png', 8, 1, 30)
	bomb_ani.set_pos(200, 200)
	lightning_ani.set_pos(300, 300)
end

function love.update(dt)
	r = r + dt * math.pi
	bomb_ani.update(dt)
	lightning_ani.update(dt)
end

function love.keypressed(key)
	if key == ' ' then
		bomb_ani.start()
		lightning_ani.start()
	end
end

function love.draw()
	local w, h = img:getDimensions()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.circle('fill', 300, 300, 10)
	love.graphics.draw(img, 300, 300, r, 1, 1, 0, 0, 0, 0)
	love.graphics.setColor(255, 0, 0, 255)
	love.graphics.draw(img, 300, 300, r, 2, 2, w/2, h/2, 0, 0)

	love.graphics.setColor(255, 255, 255, 255)
	bomb_ani.draw()
	lightning_ani.draw()
end