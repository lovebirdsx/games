require('state_manager')
require('timer_mgr')
require('render')
require('font')
require('sound')
require('event_dispatcher')
require('mode_select')
require('states')
require('game_saver')
require('chapters')

-- display live console output in sublime text2
io.stdout:setvbuf('no')

local ed = EventDispatcher:instance()
local sm = StateManager:instance()

function love.load()
	love.window.setMode(900, 600)
	love.window.setTitle('Hex')

	math.randomseed(os.time())
	timer_mgr.init()
	render.init()
	font.init()
	sound.init()
	states.init()

	sm:change_state('ModeSelect')
	GameSaver:instance():load()
	Chapters:instance():load()
end

function love.quit()
	sm:exit()
	Chapters:instance():save()
	GameSaver:instance():save()
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
	ed:send('mousepressed', x, y, button)
end

function love.mousemoved(x, y, dx, dy)
	ed:send('mousemoved', x, y, dx, dy)
end

function love.mousereleased(x, y, button)
	ed:send('mousereleased', x, y, button)
end

function love.keypressed(key)
	ed:send('keypressed', key)

	if key == 'escape' then
		love.event.quit()
	end
end
