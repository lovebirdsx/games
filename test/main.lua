local m

io.stdout:setvbuf('no')

function love.load(args)
	local name = args[2]:match('[%a_]+') 
	m = require(name)
	love.window.setTitle(name)
	if m.load then
		m.load()
	end
end

function love.update(dt)
	if m.update then
		m.update(dt)
	end
end

function love.draw()
	if m.draw then
		m.draw()
	end
end

function love.mousepressed(x, y, button)
	if m.mousepressed then
		m.mousepressed(x, y, button)
	end
end

function love.mousemoved(x, y, dx, dy)
	if m.mousemoved then
		m.mousemoved(x, y, dx, dy)
	end
end

function love.mousereleased(x, y, button)
	if m.mousereleased then
		m.mousereleased(x, y, button)
	end
end

function love.keypressed(key)	
	if m.keypressed then
		m.keypressed(key)
	end
end
