require('state_manager')
require('stage_mgr')
require('timer_mgr')
require('render')
require('font')
require('sound')
require('block_mgr')
require('game')
require('chapter_select')

-- display live console output in sublime text2
io.stdout:setvbuf('no')

local sm = StateManager:instance()

function love.load()
	love.window.setMode(900, 600)
	love.window.setTitle('Hex')

	math.randomseed(os.time())
	timer_mgr.init()
	render.init()
	font.init()
	sound.init()
	block_mgr.init()
	stage_mgr.init()

	-- sm:start(Game:new())
	sm:start(ChapterSelect:new())
end

function love.quit()
	sm:exit()
	return false
end

function love.update(dt)	
	sm:update(dt)
	timer_mgr.update(dt)
end

function love.draw()
	sm:draw()
end

function love.mousepressed(x, y, button)
	sm:mousepressed(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
	sm:mousemoved(x, y, dx, dy)
end

function love.mousereleased(x, y, button)
	sm:mousereleased(x, y, button)
end

function love.keypressed(key)
	sm:keypressed(key)
end
