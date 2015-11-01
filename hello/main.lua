require('ani')

io.stdout:setvbuf('no')

local img
local r = 0
local bomb_ani
local lightning_ani
local lightning2_ani
local bomb_img

function love.load()
	img = love.graphics.newImage('arrow2.png')
	bomb_img = love.graphics.newImage('bomb_ani.png')
	bomb_ani = ani.create('bomb_ani.png', 8, 6, 50)
	lightning_ani = ani.create('lightning_ani.png', 8, 1, 30)
	lightning2_ani = ani.create('l.png', 1, 8, 20)
	bomb_ani.set_pos(200, 200)
	lightning_ani.set_pos(300, 300)
	lightning2_ani.set_pos(400, 200)
end

function love.update(dt)
	bomb_ani.update(dt)
	lightning_ani.update(dt)
	lightning2_ani.update(dt)
end

function love.keypressed(key)
	if key == ' ' then
		-- bomb_ani.start()
		-- lightning_ani.start()
		lightning2_ani.start()
	elseif key == 'left' then
		r = r - math.rad(30)
		lightning2_ani.set_rotato(r)
	elseif key == 'right' then
		r = r + math.rad(30)
		lightning2_ani.set_rotato(r)
	end
end

function love.draw()
	love.graphics.setColor(255, 255, 255, 255)
	bomb_ani.draw()
	lightning_ani.draw()
	lightning2_ani.draw()
end