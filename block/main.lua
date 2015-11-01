require('game')
require('timer_mgr')

-- display live console output in sublime text2
io.stdout:setvbuf('no')

function love.load()
	love.window.setMode(900, 600)
	love.window.setTitle('Hex')

	math.randomseed(os.time())
	timer_mgr.init()
	game.init()	
end

function love.quit()
	game.save()
	return false
end

function love.update(dt)	
	game.update(dt)
	timer_mgr.update(dt)
end

function love.draw()
	game.render()
end
