require('board')
require('class')
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
require('event_dispatcher')

local SAVE_FILE = 'save.dat'
local VERSION = '1.1'

Game = class(State, function (self, b)
	self._board = b or board.create()
	self._selected_block = nil
	self._block_dx = 0
	self._block_dy = 0
	self._game_over = false
	self._stage_clear = false
	self._stage_failed = false
	self._score = 0
	self._explotion = nil
	self._is_highscore = false
	self._highscore = 0	
	self._auto_run = false
	self._is_auto_running = false
	self._auto_move_speed = 300
	self._turn_finish = true
	self._score_ani = {}
	self._develop = false
	self._volume = 1
	self._stage_mode = true

	self:load()
	
	if self._stage_mode then
		self:load_stage()
	end

	love.audio.setVolume(self._volume)
	sound.play('music')
end)

function Game:enter(board)
	local ed = EventDispatcher:instance()
	ed:add('mousepressed', self, self.mousepressed)
	ed:add('mousemoved', self, self.mousemoved)
	ed:add('mousereleased', self, self.mousereleased)
	ed:add('keypressed', self, self.keypressed)
end

function Game:exit()
	local ed = EventDispatcher:instance()
	ed:remove('mousepressed', self, self.mousepressed)
	ed:remove('mousemoved', self, self.mousemoved)
	ed:remove('mousereleased', self, self.mousereleased)
	ed:remove('keypressed', self, self.keypressed)

	sound.stop('music')
	self:save()
end

function Game:save()
	local save = {
		score = self._score,
		highscore = self._highscore,
		gameover = self._game_over,
		block_mgr = block_mgr.gen_snapshot(),
		stage_mgr = stage_mgr.gen_snapshot(),
		board = self._board.gen_snapshot(),
		auto_move_speed = self._auto_move_speed,
		develop = self._develop,
		auto_run = self._auto_run,
		volume = self._volume,		
		stage_mode = self._stage_mode,
		version = self.VERSION,
	}

	local s = serialize(save)
	if not love.filesystem.write(SAVE_FILE, s, #s) then
		printf('save game to %s failed', SAVE_FILE)
	end
end

function Game:load()
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
		
		block_mgr.apply_snapshot(save.block_mgr)
		stage_mgr.apply_snapshot(save.stage_mgr)

		self._score = save.score
		self._highscore = save.highscore
		self._board.apply_snapshot(save.board)
		self._game_over = save.gameover
		self._auto_move_speed = save.auto_move_speed
		self._develop = save.develop
		self._auto_run = save.auto_run
		self._volume = save.volume	
		self._stage_mode = save.stage_mode
	end
end

function Game:load_prev_stage(count)
	if self._stage_mode then
		stage_mgr.move_to_prev_stage(count)
		self:load_stage()
	end
end

function Game:load_next_stage(count)
	if self._stage_mode then		
		stage_mgr.move_to_next_stage(count)
		self:load_stage()
	end
end

function Game:load_stage()
	local board, blocks, move = stage_mgr.load_current()
	if board then
		self._board = board
		block_mgr.update(blocks)
		self._stage_clear = false

		local m = move
		while m do
			print(string.format('move = id[%d], type[%d]', m.block_pos, m.block.type))
			m = m.next_move
		end
	end
end

function Game:restart()
	self._game_over =false
	self._score = 0
	self._is_highscore = false
	self._selected_block = nil
	self._board = board.create()
	block_mgr.init()	

	sound.stop('gameover')
	sound.play('music')
end

function Game:restart_stage()
	self._stage_failed = false
	self._stage_clear = false
	self._score = 0
	self._selected_block = nil
	self:load_stage()
	sound.stop('gameover')
	sound.play('music')
end

function Game:update(dt)	
	self._board.update(dt)
	if self._explotion then
		self._explotion.update(dt)
	end

	for _, ani in ipairs(self._score_ani) do
		ani.update(dt)
	end	

	if self._develop and self._auto_run and self._turn_finish then
		self:auto_move()
	end
end

function Game:auto_move()
	if not self._turn_finish then
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
		local h = self._board.get_hex(move.rx, move.ry)
		local ex, ey = h.x, h.y
		local move_time = ((ex-sx) ^ 2 + (ey - sy) ^ 2) ^ 0.5 / self._auto_move_speed
		self:start_move_block(move.block, sx, sy)
		self._is_auto_running = true
		local ti = timer.create()
		ti.start(1/30, true, function (t)
			t = t - ai_time
			if t < move_time then
				local x = sx + (ex - sx) * t / move_time
				local y = sy + (ey - sy) * t / move_time
				self:move_block(x, y)
			else
				self:move_block(ex, ey)
				self:locate_block(ex, ey)
				ti.stop()
				self._is_auto_running = false
			end
		end)
	end
end

local _key_routines = {
	['delete'] = function (self)
		if _stage_mode then
			stage_mgr.del()
			Game:load_stage()
		end
	end,
	['t'] = function (self)
		self._stage_mode = not self._stage_mode
		if self._stage_mode then
			self:load_stage()
		else
			self:restart()
		end
	end,	
	['left'] = function (self)
		local count = 1
		if love.keyboard.isDown('lctrl') then
			count = 10
		elseif love.keyboard.isDown('lalt') then
			count = 100
		end
		self:load_prev_stage(count)
	end,

	['right'] = function (self)		
		local count = 1
		if love.keyboard.isDown('lctrl') then
			count = 10
		elseif love.keyboard.isDown('lalt') then
			count = 100
		end
		self:load_next_stage(count)
	end,
	['g'] = function (self)
		if self._develop and self._turn_finish then
			self:auto_move()
		end
	end,
	['r'] = function (self)
		if self._stage_mode then
			self:load_stage()
		else
			self:restart()
		end
	end,
	['a'] = function (self)
		if self._develop then
			self._auto_run = not self._auto_run
		end
	end,
	['d'] = function (self)
		self._develop = not self._develop		
	end,
	['up'] = function (self)
		self._auto_move_speed = self._auto_move_speed * 2
	end,
	['down'] = function (self)
		self._auto_move_speed = self._auto_move_speed / 2
	end,
	['h'] = function (self)
		print(self._board.excel_string())
	end,
	['s'] = function (self)
		self._volume = self._volume == 1 and 0 or 1		
		love.audio.setVolume(self._volume)
	end,
	['i'] = function (self)
		if not self._stage_mode then
			self._board.random_icing()
		end
	end,
	['b'] = function (self)
		if not self._stage_mode then
			self._board.random_bomb()
		end
	end,
	['n'] = function (self)
		if not self._stage_mode then
			self._board.random_2arrow()
		end
	end,
	['o'] = function (self)
		if not self._stage_mode then
			self._board.random_rope()
		end
	end,
	[' '] = function (self)
		if self._game_over or self._stage_clear or self._stage_failed then
			if not self._stage_mode then
				self:restart()
			else
				if self._stage_failed then
					self:restart_stage()
				else
					self:load_next_stage()
				end
			end
		end		
	end,
	['j'] = function (self)
		self._board.set_pos_and_scale(100, 100, 0.2)
	end
}

function Game:keypressed(key)
	local f = _key_routines[key]
	if f then f(self) end
end

function Game:draw()
	render.draw_bg()
	self._board.draw()
	if self._explotion then
		self._explotion.draw()
	end

	for _, ani in ipairs(self._score_ani) do
		ani.draw()
	end

	block_mgr.draw()

	love.graphics.setColor(255, 255, 255, 255)
	if self._stage_mode then
		-- font.print('big', string.format('[%d/%d] %s', 
		-- 	stage_mgr.stage_id(), stage_mgr.stage_total(), stage_mgr.stage_file()), 30, 10)
	else
		font.print('hurge', string.format('%d', self._score), 400, 10)
		font.print('big', string.format('Best: %d', self._highscore), 30, 10)
	end

	if self._develop then
		font.print('normal', string.format('auto[%s] stage_mode[%s] [%d/%d] %s', 
			self._auto_run, self._stage_mode, stage_mgr.stage_id(), 
			stage_mgr.stage_total(), stage_mgr.stage_file()), 30, 580)
	end

	if self._game_over then
		love.graphics.setColor(0, 0, 0, 192)
		love.graphics.rectangle('fill', 0, 0, 
			love.window.getWidth(), love.window.getHeight())
		
		if self._is_highscore then
			love.graphics.setColor(123, 212, 57, 255)
			font.print('hurge', string.format('High score: %d !', self._score),
				300, 250)
		else
			love.graphics.setColor(255, 20, 20, 255)
			font.print('hurge', 'GameOver', 350, 250)
		end
	end

	if self._stage_clear then
		love.graphics.setColor(0, 0, 0, 192)
		love.graphics.rectangle('fill', 0, 0, 
			love.window.getWidth(), love.window.getHeight())		
		love.graphics.setColor(123, 212, 57, 255)
		font.print('hurge', 'Stage Clear', 350, 250)
	end

	if self._stage_failed then
		love.graphics.setColor(0, 0, 0, 192)
		love.graphics.rectangle('fill', 0, 0, 
			love.window.getWidth(), love.window.getHeight())
		love.graphics.setColor(255, 20, 20, 255)
		font.print('hurge', 'Stage Failed', 350, 250)
	end
end

function Game:can_locate_any_block()
	for _, b in ipairs(block_mgr.blocks()) do
		if self._board.can_locate_any(b) then
			return true
		end
	end
	return false
end

function Game:start_move_block_by_pos(x, y)
	if not self._selected_block and self._turn_finish then
		local b = block_mgr.get_block_by_pos(x, y)
		if b then
			self:start_move_block(b, x, y)
		end		
	end
end

function Game:start_move_block(b, x ,y)
	block_mgr.select_block(b)
	self._turn_finish = false
	self._selected_block = b
	self._block_dx = x - b.x
	self._block_dy = y - b.y
	sound.play('pickup')
end

function Game:move_block(x, y)
	if self._selected_block then
		self._selected_block.set_pos(x - self._block_dx, y - self._block_dy)
		self._board.unfocus()
		if self._board.can_locate(self._selected_block) then
			self._board.focus(self._selected_block)
		end
	end
end

function Game:gameover()
	self._game_over = true
	sound.stop('music')
	if self._score > self._highscore then
		self._highscore = self._score
		self._is_highscore = true
		self:save()
		sound.play('highscore')
	else
		sound.play('gameover')
	end
end

function Game:stage_clear()
	sound.play('highscore')
	self._stage_clear = true
end

function Game:stage_faild()
	sound.stop('music')
	sound.play('gameover')
	self._stage_failed = true
end

function Game:add_score_ani(score, rx, ry)
	local h = self._board.get_hex(rx, ry)
	local ani = text_effect.create('+' .. score, h.x, h.y - 100)
	table.insert(self._score_ani, ani)
	ani.on_end(function ()
		for i, a in ipairs(self._score_ani) do
			if a == ani then
				table.remove(self._score_ani, i)
				return
			end
		end
	end)
end

function Game:check_end()
	if not self._stage_mode then
		if not self:can_locate_any_block() then
			self:gameover()
		end
	else
		if self._board.is_all_clear() and block_mgr.is_clear() then
			self:stage_clear()
		else
			if not self:can_locate_any_block() then
				self:stage_faild()
			end
		end
	end
end

function Game:locate(b, rx, ry)
	self._board.locate_by_rx_ry(b, rx, ry)
	block_mgr.remove_select()
	
	local current_s = score.block_score(b)
	self._score = self._score + current_s
	self:add_score_ani(current_s, rx, ry)
	sound.play('place')

	if self._board.can_line_up() then
		local result = self._board.get_lineup_rows()
		self._turn_finish = false
		self._board.start_lineup_ani(function ()
			self._turn_finish = true
			if #result > 1 then
				sound.play_tier(#result - 1)
			end
			local current_s = score.line_up_score(result)
			self._score = self._score + current_s
			self:add_score_ani(current_s, rx, ry)
			if not self._stage_mode then
				block_mgr.refill()
			end
			self:check_end()
		end)
	else
		self._turn_finish = true
		if not self._stage_mode then
			block_mgr.refill()
		end

		self:check_end()
	end
end

function Game:locate_block(x, y)
	if self._selected_block then
   		if self._board.can_locate(self._selected_block) then
   			local h = self._board.get_hex_by_pos(self._selected_block.x,
   				self._selected_block.y)
   			self:locate(self._selected_block, h.rx, h.ry)
   		else
   			self._turn_finish = true
   			block_mgr.unselect()   			
   			sound.play('placewrong')
		end
   		self._selected_block = nil
   	end
end

function Game:mousepressed(x, y, button)
	if button == 'l'  then
		if self._game_over or self._stage_clear or self._stage_failed then
			if not self._stage_mode then
				self:restart()
			else
				if self._stage_failed then
					self:restart_stage()
				else
					self:load_next_stage()
				end
			end
		else
			if not self._is_auto_running then
				self:start_move_block_by_pos(x, y)		
			end
		end
	end

	if button == 'r' then
		if self._stage_mode then
			self:restart_stage()
		else
			self:restart()
		end
	end
end

function Game:mousemoved(x, y, dx, dy)
	if not self._is_auto_running then
		self:move_block(x, y)
	end
end

function Game:mousereleased(x, y, button)
   	if button == "l" and not self._is_auto_running then
   		self:locate_block(x, y)
   	end
end
