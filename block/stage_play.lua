require('state_manager')
require('play')
require('button')
require('event_dispatcher')
require('stage')

StagePlay = class(State, function (self, path)
	self.path = path
	self.play = Play()
	self.buttons = Buttons()	

	local ed = EventDispatcher:instance()
	ed:add('mousepressed', self, self.mousepressed)

	local screen_w = love.graphics.getWidth()
	local back_button = Button('Back', screen_w - 100, 20, 100, 50)
	back_button.on_click = function (self)		
		StateManager:instance():change_state('StageSelect')
	end

	local restart_button = Button('Restart', screen_w - 100 - 80, 20, 100, 50)
	restart_button.on_click = function (b)
		self:restart()
	end

	self.buttons:add(restart_button)
	self.buttons:add(back_button)

	self:load()
end)

function StagePlay:load()
	local board, blocks, move = stage.load(self.path)

	self.play.board = board

	local block_generator = self.play.block_generator
	block_generator:set_max_block_count(#blocks)
	block_generator:update_blocks(blocks)
	block_generator:set_can_refill(false)

	if #blocks == 3 then
		block_generator:set_pos(700, 150)
	elseif #blocks == 4 then
		block_generator:set_pos(700, 120)
	end
end

function StagePlay:exit()
	local ed = EventDispatcher:instance()
	ed:remove('mousepressed', self, self.mousepressed)

	self.buttons:release()
end

function StagePlay:update(dt)
	self.play:update(dt)
end

function StagePlay:draw()
	self.play:draw()
	self.buttons:draw()

	if self.play:is_end() then
		if self.play.board.is_all_clear() then
			love.graphics.setColor(0, 0, 0, 192)
			love.graphics.rectangle('fill', 0, 0, 
				love.window.getWidth(), love.window.getHeight())
			love.graphics.setColor(123, 212, 57, 255)
			font.print('hurge', 'Stage Clear', 350, 250)
		else
			love.graphics.setColor(0, 0, 0, 192)
			love.graphics.rectangle('fill', 0, 0, 
				love.window.getWidth(), love.window.getHeight())
			love.graphics.setColor(255, 20, 20, 255)
			font.print('hurge', 'Stage Failed', 350, 250)
		end
	end
end

function StagePlay:restart()
	self.play:reset()
	self:load()
end

function StagePlay:mousepressed(x, y, button)
	if self.play:is_end() then
		if button == 'l' then
			if self.play.board.is_all_clear() then
				StateManager:instance():change_state('StageSelect')
			else
				self:restart()
			end
		end
	end
end
