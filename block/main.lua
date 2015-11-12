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
require('text_effect')

-- display live console output in sublime text2
io.stdout:setvbuf('no')

local ed = EventDispatcher:instance()
local sm = StateManager:instance()

local LUAFILE_TO_STATE = {
	['stage_filter.lua'] = 'StageFilter',
	['stage_dir.lua'] = 'StageFilter',
	['mode_select.lua'] = 'ModeSelect',	
	['endless_play.lua'] = 'EndlessPlay',
	['stage_play.lua'] = 'StagePlay',
	['run_test.lua'] = 'RunTest',
	['test.lua'] = 'RunTest',
}

function get_start_state(lua_file)	
	local state = LUAFILE_TO_STATE[lua_file]
	if not state then
		state = 'ModeSelect'
	end	
	return state
end

function love.load(args)
	love.window.setMode(900, 600)
	love.window.setTitle('Hex')

	math.randomseed(os.time())
	timer_mgr.init()
	render.init()
	font.init()
	sound.init()
	states.init()
	
	sm:change_state(get_start_state(args[2]))
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
	text_effect_mgr.update(dt)
end

function love.draw()
	sm:draw()
	text_effect_mgr.draw()
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
	debug('main: [%s] pressed', key)
	ed:send('keypressed', key)

	if key == 'escape' then
		love.event.quit()
	end
end
