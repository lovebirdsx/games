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
require('setting')

-- display live console output in sublime text2
io.stdout:setvbuf('no')

local ed = EventDispatcher:instance()
local sm = StateManager:instance()

local LUAFILE_TO_STATE = {
	['stage_filter.lua'] = 'StageFilter',
	['stage_dir.lua'] = 'StageFilter',
	['mode_select.lua'] = 'ModeSelect',	
	['endless_play.lua'] = 'EndlessPlay',
	['block_generator.lua'] = 'EndlessPlay',
	['stage_play.lua'] = 'StagePlay',
	['run_test.lua'] = 'RunTest',
	['test.lua'] = 'RunTest',
	['send_record.lua'] = 'SendRecord',
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
	
	GameSaver:instance():load()
	Chapters:instance():load()
	Setting:instance():load()

	states.init()
	sm:change_state(get_start_state(args[2]))
end

function love.quit()
	sm:exit()
	Setting:instance():save()
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

local KEY_FUNS = {
	['escape'] = love.event.quit,
	['s'] = function () Setting:instance():troggle_sound() end,
	['1'] = function () Setting:instance():set_log_level('debug') end,
	['2'] = function () Setting:instance():set_log_level('info') end,
	['3'] = function () Setting:instance():set_log_level('warning') end,
	['4'] = function () Setting:instance():set_log_level('fatal') end,
}

function love.keypressed(key)	
	ed:send('keypressed', key)

	local fun = KEY_FUNS[key]
	if fun then fun() end
end
