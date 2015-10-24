function printf(fmt, ...)
	print(string.format(fmt, ...))
end

local _canvas
local _image
local _quads
local _quad_id
local _ps

function change_particle_image()
	love.graphics.setCanvas(_canvas)
		_canvas:clear()
		love.graphics.setBlendMode('alpha')
		love.graphics.setColor(255, 0, 0, 255)
		love.graphics.draw(_image, _quads[_quad_id], 0, 0)		
	love.graphics.setCanvas()
end

function create_quads()
	local w, h = 128 / 4,  128 / 4
	local quads = {}
	for c=1,4 do
		for r=1,4 do
			table.insert(quads, love.graphics.newQuad((c-1)*w, (r-1)*h, w, h, 128, 128))
		end
	end
	return quads
end

function love.load()
	_canvas = love.graphics.newCanvas(128/4, 128/4, 'normal')
	_image = love.graphics.newImage('particles.png')
	_quads = create_quads()
	_quad_id = 1
	_ps = love.graphics.newParticleSystem(_canvas, 1024)
	_ps:setParticleLifetime(2, 5) -- Particles live at least 2s and at most 5s.
	-- _ps:setEmissionRate(5)
	_ps:setSizeVariation(1)
	_ps:setLinearAcceleration(-20, -20, 20, 20) -- Random movement in all directions.
	_ps:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to transparency.

	change_particle_image()
end

function love.update(dt)
	_ps:update(dt)
end

function love.draw()
	love.graphics.setBlendMode('premultiplied')
	love.graphics.draw(_canvas, 100, 100)
	love.graphics.draw(_ps, 400, 300)
end

local _key_routines = {
	['up'] = function ()
		_quad_id = _quad_id + 1
		if _quad_id > #_quads then
			_quad_id = 1
		end
		change_particle_image()
	end,
	['down'] = function ()
		_quad_id = _quad_id - 1
		if _quad_id < 1 then
			_quad_id = #_quads
		end
		change_particle_image()
	end,
	['escape'] = function ()
		love.event.quit()
	end,
	[' '] = function ()
		_ps:emit(32)
	end
}

function love.keypressed(key)
	local f = _key_routines[key]
	if f then f() end
end
