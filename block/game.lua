require('board')
require('block')
require('render')
require('block_mgr')
require('score')
require('font')
require('sound')
require('ai')
require('text_effect')
require('timer')
require('stage')
require('misc')
require('stage_mgr')

local SAVE_FILE = 'save.dat'
local VERSION = '1.1'

game = {}

local _selected_block = nil
local _block_dx = 0
local _block_dy = 0
local _game_over = false
local _stage_clear = false
local _stage_failed = false
local _score = 0
local _explotion = nil
local _is_highscore = false
local _highscore = 0
local _board = nil
local _auto_run = false
local _is_auto_running = false
local _auto_move_speed = 300
local _turn_finish = true
local _score_ani = {}
local _develop = false
local _volume = 1
local _stage_mode = true

function game.init()
	render.init()
	font.init()
	sound.init()
	block_mgr.init()
	stage_mgr.init()
	_board = board.create()
	game.load()
	
	if _stage_mode then
		game.load_stage()
	end

	love.audio.setVolume(_volume)
	sound.play('music')
end

function game.save()
	local save = {
		score = _score,
		highscore = _highscore,
		gameover = _game_over,
		block_mgr = block_mgr.gen_snapshot(),
		stage_mgr = stage_mgr.gen_snapshot(),
		board = _board.gen_snapshot(),
		auto_move_speed = _auto_move_speed,
		develop = _develop,
		auto_run = _auto_run,
		volume = _volume,		
		stage_mode = _stage_mode,
		version = VERSION,
	}

	local s = serialize(save)
	if not love.filesystem.write(SAVE_FILE, s, #s) then
		printf('save game to %s failed', SAVE_FILE)
	end
end

function game.load()
	local s = love.filesystem.read(SAVE_FILE)
	if not s then
		printf('game load from %s failed', SAVE_FILE)
		return
	end

	local save = unserialize(s)
	if not save then
		printf('game load failed: unserialize failed')
		return
	end

	if save.version and save.version == VERSION then		
		_score = save.score
		_highscore = save.highscore
		block_mgr.apply_snapshot(save.block_mgr)
		stage_mgr.apply_snapshot(save.stage_mgr)
		_board.apply_snapshot(save.board)
		_game_over = save.gameover
		_auto_move_speed = save.auto_move_speed
		_develop = save.develop
		_auto_run = save.auto_run
		_volume = save.volume	
		_stage_mode = save.stage_mode
	end
end

function game.load_prev_stage()
	if _stage_mode then
		stage_mgr.move_to_prev_stage()
		game.load_stage()
	end
end

function game.load_next_stage()
	if _stage_mode then		
		stage_mgr.move_to_next_stage()
		game.load_stage()
	end
end

function game.load_stage()
	local board, blocks, move = stage_mgr.load_current()
	if board then
		_board = board
		block_mgr.update(blocks)
		_stage_clear = false

		local m = move
		while m do
			print(string.format('move = id[%d], type[%d]', m.block_pos, m.block.type))
			m = m.next_move
		end
	end
end

function game.restart()
	_game_over =false
	_score = 0
	_is_highscore = false
	_selected_block = nil
	_board = board.create()
	block_mgr.init()	

	sound.stop('gameover')
	sound.play('music')
end

function game.restart_stage()
	_stage_failed = false
	_stage_clear = false
	_score = 0
	_selected_block = nil
	game.load_stage()
	sound.stop('gameover')
	sound.play('music')
end

function game.update(dt)
	_board.update(dt)
	if _explotion then
		_explotion.update(dt)
	end

	for _, ani in ipairs(_score_ani) do
		ani.update(dt)
	end	

	if _develop and _auto_run and _turn_finish then
		game.auto_move()
	end
end

function game.auto_move()
	if not _turn_finish then
		return
	end

	local start_time = love.timer.getTime( )
	local move, score = ai.get_best_move(_board,
		block_mgr.blocks())
	local end_time = love.timer.getTime()
	local ai_time = end_time - start_time

	if not move then
		print('No best move')
	else
		print(string.format('Move block[%d] %d to %d %d, socre = %d',
			move.block.type, move.block.id, move.rx, move.ry, score))
		local sx, sy = move.block.x, move.block.y
		local h = _board.get_hex(move.rx, move.ry)
		local ex, ey = h.x, h.y
		local move_time = ((ex-sx) ^ 2 + (ey - sy) ^ 2) ^ 0.5 / _auto_move_speed
		game.start_move_block(move.block, sx, sy)
		_is_auto_running = true
		local ti = timer.create()
		ti.start(1/30, true, function (t)
			t = t - ai_time
			if t < move_time then
				local x = sx + (ex - sx) * t / move_time
				local y = sy + (ey - sy) * t / move_time
				game.move_block(x, y)
			else
				game.move_block(ex, ey)
				game.locate_block(ex, ey)
				ti.stop()
				_is_auto_running = false
			end
		end)
	end
end

local _key_routines = {
	['delete'] = function ()
		if _stage_mode then
			stage_mgr.del()
			game.load_stage()
		end
	end,
	['escape'] = function ()
		love.event.quit()
	end,
	['t'] = function ()
		_stage_mode = not _stage_mode
		if _stage_mode then
			game.load_stage()
		else
			game.restart()
		end
	end,	
	['left'] = function ()
		game.load_prev_stage()
	end,

	['right'] = function ()		
		game.load_next_stage()
	end,
	['g'] = function ()
		if _develop and _turn_finish then
			game.auto_move()
		end
	end,
	['r'] = function ()
		if _stage_mode then
			game.load_stage()
		else
			game.restart()
		end
	end,
	['a'] = function ()
		if _develop then
			_auto_run = not _auto_run
		end
	end,
	['d'] = function ()
		_develop = not _develop		
	end,
	['up'] = function ()
		_auto_move_speed = _auto_move_speed * 2
	end,
	['down'] = function ()
		_auto_move_speed = _auto_move_speed / 2
	end,
	['h'] = function ()
		print(_board.excel_string())
	end,
	['s'] = function ()
		_volume = _volume == 1 and 0 or 1		
		love.audio.setVolume(_volume)
	end,
	['i'] = function ()
		if not _stage_mode then
			_board.random_icing()
		end
	end,
	['b'] = function ()
		if not _stage_mode then
			_board.random_bomb()
		end
	end,
	['n'] = function ()
		if not _stage_mode then
			_board.random_2arrow()
		end
	end,
}

function love.keypressed(key)
	printf('key [%s] pressed', key)
	local f = _key_routines[key]
	if f then f() end
end

function game.render()
	render.draw_bg()
	_board.draw()
	if _explotion then
		_explotion.draw()
	end

	for _, ani in ipairs(_score_ani) do
		ani.draw()
	end

	block_mgr.draw()

	love.graphics.setColor(255, 255, 255, 255)
	if _stage_mode then
		-- font.print('big', string.format('[%d/%d] %s', 
		-- 	stage_mgr.stage_id(), stage_mgr.stage_total(), stage_mgr.stage_file()), 30, 10)
	else
		font.print('hurge', string.format('%d', _score), 400, 10)
		font.print('big', string.format('Best: %d', _highscore), 30, 10)
	end

	if _develop then
		font.print('normal', string.format('auto[%s] stage_mode[%s] [%d/%d] %s', 
			_auto_run, _stage_mode, stage_mgr.stage_id(), stage_mgr.stage_total(), stage_mgr.stage_file()), 30, 580)
	end

	if _game_over then
		love.graphics.setColor(0, 0, 0, 192)
		love.graphics.rectangle('fill', 0, 0, 
			love.window.getWidth(), love.window.getHeight())
		
		if _is_highscore then
			love.graphics.setColor(123, 212, 57, 255)
			font.print('hurge', string.format('High score: %d !', _score),
				300, 250)
		else
			love.graphics.setColor(255, 20, 20, 255)
			font.print('hurge', 'GameOver', 350, 250)
		end
	end

	if _stage_clear then
		love.graphics.setColor(0, 0, 0, 192)
		love.graphics.rectangle('fill', 0, 0, 
			love.window.getWidth(), love.window.getHeight())		
		love.graphics.setColor(123, 212, 57, 255)
		font.print('hurge', 'Stage Clear', 350, 250)
	end

	if _stage_failed then
		love.graphics.setColor(0, 0, 0, 192)
		love.graphics.rectangle('fill', 0, 0, 
			love.window.getWidth(), love.window.getHeight())
		love.graphics.setColor(255, 20, 20, 255)
		font.print('hurge', 'Stage Failed', 350, 250)
	end
end

function game.can_locate_any_block()
	for _, b in ipairs(block_mgr.blocks()) do
		if _board.can_locate_any(b) then
			return true
		end
	end
	return false
end

function game.start_move_block_by_pos(x, y)
	if not _selected_block and _turn_finish then
		local b = block_mgr.get_block_by_pos(x, y)
		if b then
			game.start_move_block(b, x, y)
		end		
	end
end

function game.start_move_block(b, x ,y)
	block_mgr.select_block(b)
	_turn_finish = false
	_selected_block = b
	_block_dx = x - _selected_block.x
	_block_dy = y - _selected_block.y
	sound.play('pickup')
end

function game.move_block(x, y)
	if _selected_block then
		_selected_block.set_pos(x - _block_dx, y - _block_dy)
		_board.unfocus()
		if _board.can_locate(_selected_block) then			
			_board.focus(_selected_block)
		end
	end
end

function game.gameover()
	_game_over = true
	sound.stop('music')
	if _score > _highscore then
		_highscore = _score
		_is_highscore = true
		game.save()
		sound.play('highscore')
	else
		sound.play('gameover')
	end
end

function game.stage_clear()
	sound.play('highscore')
	_stage_clear = true
end

function game.stage_faild()
	_stage_failed = true
	sound.stop('music')
	sound.play('gameover')
end

function game.add_score_ani(score, rx, ry)
	local h = _board.get_hex(rx, ry)
	local ani = text_effect.create('+' .. score, h.x, h.y - 100)
	table.insert(_score_ani, ani)
	ani.on_end(function ()
		for i, a in ipairs(_score_ani) do
			if a == ani then
				table.remove(_score_ani, i)
				return
			end
		end
	end)
end

function game.check_end()
	if not _stage_mode then
		if not game.can_locate_any_block() then
			game.gameover()
		end
	else
		if _board.is_all_clear() and block_mgr.is_clear() then
			game.stage_clear()
		else
			if not game.can_locate_any_block() then
				game.stage_faild()
			end
		end
	end
end

function game.locate(b, rx, ry)
	_board.locate_by_rx_ry(b, rx, ry)
	block_mgr.remove_select()
	
	local current_s = score.block_score(b)
	_score = _score + current_s
	game.add_score_ani(current_s, rx, ry)
	sound.play('place')

	if _board.can_line_up() then
		local result = _board.get_lineup_rows()
		_turn_finish = false
		_board.start_lineup_ani(function ()
			_turn_finish = true
			if #result > 1 then
				sound.play_tier(#result - 1)
			end
			local current_s = score.line_up_score(result)
			_score = _score + current_s
			game.add_score_ani(current_s, rx, ry)
			if not _stage_mode then
				block_mgr.refill()
			end
			game.check_end()
		end)
	else
		_turn_finish = true
		if not _stage_mode then
			block_mgr.refill()
		end

		game.check_end()
	end
end

function game.locate_block(x, y)
	if _selected_block then
   		if _board.can_locate(_selected_block) then
   			local h = _board.get_hex_by_pos(_selected_block.x,
   				_selected_block.y)
   			game.locate(_selected_block, h.rx, h.ry)
   		else
   			_turn_finish = true
   			block_mgr.unselect()   			
   			sound.play('placewrong')
		end
   		_selected_block = nil
   	end
end

function love.mousepressed(x, y, button)
	if button == 'l'  then
		if _game_over or _stage_clear or _stage_failed then
			if not _stage_mode then
				game.restart()
			else
				if _stage_failed then
					game.restart_stage()
				else
					game.load_next_stage()
				end
			end
		else
			if not _is_auto_running then
				game.start_move_block_by_pos(x, y)		
			end
		end
	end

	if button == 'r' then
		if _stage_mode then
			game.restart_stage()
		else
			game.restart()
		end
	end
end

function love.mousemoved(x, y, dx, dy)
	if not _is_auto_running then
		game.move_block(x, y)
	end
end

function love.mousereleased(x, y, button)
   	if button == "l" and not _is_auto_running then
   		game.locate_block(x, y)
   	end
end
