require('board')
require('render')
require('score')
require('font')
require('ai')
require('text_effect')
require('timer')
require('stage')
require('misc')
require('event_dispatcher')
require('block_generator')
require('log')

Play = class(function (self)
	self.board = board.create()
	self.selected_block = nil
	self.block_dx = 0
	self.block_dy = 0
	self.score = 0
	self.explotion = nil
	self.auto_run = false
	self.is_auto_running = false
	self.auto_move_speed = 300
	self.turn_finish = true
	self.score_ani = {}
	self.develop = false
	self.block_generator = BlockGenerator(3)
	self.play_end = false

	local ed = EventDispatcher:instance()
	ed:add('mousepressed', self, self.mousepressed)
	ed:add('mousemoved', self, self.mousemoved)
	ed:add('mousereleased', self, self.mousereleased)
	ed:add('keypressed', self, self.keypressed)
end)

function Play:release()
	local ed = EventDispatcher:instance()
	ed:remove('mousepressed', self, self.mousepressed)
	ed:remove('mousemoved', self, self.mousemoved)
	ed:remove('mousereleased', self, self.mousereleased)
	ed:remove('keypressed', self, self.keypressed)
end

function Play:gen_snapshot()
	local s = {
		score = self.score,
		board = self.board.gen_snapshot(),
		develop = self.develop,		
		auto_move_speed = self.auto_move_speed,
		block_generator = self.block_generator:gen_snapshot()
	}
	return s
end

function Play:apply_snapshot(s)
	self.score = s.score	
	self.auto_move_speed = s.auto_move_speed
	self.develop = s.develop
	self.board.apply_snapshot(s.board)
	self.block_generator:apply_snapshot(s.block_generator)
end

function Play:on_end(cb)
	self.on_end_cb = cb
end

function Play:update(dt)	
	self.board.update(dt)
	if self.explotion then
		self.explotion.update(dt)
	end	

	if self.develop and self.auto_run and self.turn_finish then
		self:auto_move()
	end
end

function Play:auto_move()
	if not self.turn_finish then
		return
	end

	local start_time = love.timer.getTime( )
	local move, score = ai.get_best_move(self.board,
		self.block_generator:get_blocks())
	local end_time = love.timer.getTime()
	local ai_time = end_time - start_time

	if not move then
		debug('Play: No best move')
	else
		debug('Play: Move block[%d] %d to %d %d, socre = %d',
			move.block.type, move.block.id, move.rx, move.ry, score)
		local sx, sy = move.block.x, move.block.y
		local h = self.board.get_hex(move.rx, move.ry)
		local ex, ey = h.x, h.y
		local move_time = ((ex-sx) ^ 2 + (ey - sy) ^ 2) ^ 0.5 / self.auto_move_speed
		self:start_move_block(move.block, sx, sy)
		self.is_auto_running = true
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
				self.is_auto_running = false
			end
		end)
	end
end

local KEY_FUNS = {
	['g'] = function (self)
		if self.develop and self.turn_finish then
			debug('Play: auto move start')
			self:auto_move()
			debug('Play: auto move end')
		end
	end,
	['a'] = function (self)
		if self.develop then
			self.auto_run = not self.auto_run
			debug('Play: auto_run %s', self.auto_run)
		end
	end,
	['d'] = function (self)
		self.develop = not self.develop
		debug('Play: develop %s', self.develop)
	end,
	['up'] = function (self)
		self.auto_move_speed = self.auto_move_speed * 2
		debug('Play: auto_move_speed %g', self.auto_move_speed)
	end,
	['down'] = function (self)
		self.auto_move_speed = self.auto_move_speed / 2
		debug('Play: auto_move_speed %g', self.auto_move_speed)
	end,	
}

function Play:keypressed(key)
	local f = KEY_FUNS[key]
	if f then f(self) end
end

function Play:draw()	
	self.board.draw()
	if self.explotion then
		self.explotion.draw()
	end

	self.block_generator:draw()	
end

function Play:can_locate_any_block()
	for _, b in ipairs(self.block_generator:get_blocks()) do
		if self.board.can_locate_any(b) then
			return true
		end
	end
	return false
end

function Play:start_move_block_by_pos(x, y)
	if not self.selected_block and self.turn_finish then
		local b = self.block_generator:get_block_by_pos(x, y)
		if b then
			self:start_move_block(b, x, y)
		end		
	end
end

function Play:start_move_block(b, x ,y)
	self.block_generator:select_block(b)
	self.turn_finish = false
	self.selected_block = b
	self.block_dx = x - b.x
	self.block_dy = y - b.y
	sound.play('pickup')
end

function Play:move_block(x, y)
	if self.selected_block then
		self.selected_block.set_pos(x - self.block_dx, y - self.block_dy)
		self.board.unfocus()
		if self.board.can_locate(self.selected_block) then
			self.board.focus(self.selected_block)
		end
	end
end

function Play:addscore_ani(score, rx, ry)
	local h = self.board.get_hex(rx, ry)
	text_effect.create('+' .. score, h.x, h.y - 100)
end

function Play:is_end()
	return self.play_end
end

function Play:check_end()
	if not self:can_locate_any_block() or self.block_generator:is_clear() then
		self.play_end = true
		if self.on_end_cb then
			self.on_end_cb()
		end
	end
end

function Play:locate(b, rx, ry)
	self.board.locate_by_rx_ry(b, rx, ry)
	self.block_generator:remove_select()
	
	local current_s = score.block_score(b)
	self.score = self.score + current_s
	self:addscore_ani(current_s, rx, ry)
	sound.play('place')

	if self.board.can_line_up() then
		local result = self.board.get_lineup_rows()
		self.turn_finish = false
		self.board.start_lineup_ani(function ()
			self.turn_finish = true
			local current_s = score.lineup_score(result)
			self.score = self.score + current_s
			self:addscore_ani(current_s, rx, ry)
			self.block_generator:refill()
			self:check_end()
		end)
	else
		self.turn_finish = true
		self.block_generator:refill()
		self:check_end()
	end
end

function Play:locate_block(x, y)
	if self.selected_block then
   		if self.board.can_locate(self.selected_block) then
   			local h = self.board.get_hex_by_pos(self.selected_block.x,
   				self.selected_block.y)
   			self:locate(self.selected_block, h.rx, h.ry)
   		else
   			self.turn_finish = true
   			self.block_generator:unselect()   			
   			sound.play('placewrong')
		end
   		self.selected_block = nil
   	end
end

function Play:reset()
	self.score = 0
	self.selected_block = nil
	self.play_end = false
	self.board:clear_all()
	self.block_generator:fill_all()
end

function Play:mousepressed(x, y, button)
	if button == 'l'  then
		if not self.is_auto_running then
			self:start_move_block_by_pos(x, y)
		end		
	end
end

function Play:mousemoved(x, y, dx, dy)
	if not self.is_auto_running then
		self:move_block(x, y)
	end
end

function Play:mousereleased(x, y, button)
   	if button == "l" and not self.is_auto_running then
   		self:locate_block(x, y)
   	end
end
