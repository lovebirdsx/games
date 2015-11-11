require('state_manager')
require('play')
require('button')
require('event_dispatcher')
require('stage_loader')
require('sound')

StagePlay = class(function (self, stage)
	self.stage = stage
	self.play = Play()
	self:load()
	sound.play('music')	
end)

function StagePlay:load()
	local board, blocks, move = stage_loader.load(self.stage.path)

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

function StagePlay:set_pos_and_scale(x, y, scale)
	self.x, self.y, self.scale = x, y, scale
	self.play.board.set_pos_and_scale(x, y, scale)
	self.play.block_generator:set_pos(700 + (x - 300) * scale * 0.5, 150)
	self.play.block_generator:set_scale(scale)
end

function StagePlay:release()
	self.play:release()
	sound.stop('music')
end

function StagePlay:update(dt)
	self.play:update(dt)
end

function StagePlay:draw()
	self.play:draw()

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

	if self.scale then
		self:set_pos_and_scale(self.x, self.y, self.scale)
	end
end

function StagePlay:is_end()
	return self.play:is_end()
end

function StagePlay:succeed()
	return self.play.board.is_all_clear()
end
