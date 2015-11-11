require('state_manager')
require('stage_play')
require('button')
require('event_dispatcher')

PlayStage = class(State, function (self, stage)	
	self.play = StagePlay(stage)
	self.buttons = Buttons()
	self.stage = stage

	local ed = EventDispatcher:instance()
	ed:add('mousepressed', self, self.mousepressed)

	local screen_w = love.graphics.getWidth()
	local back_button = Button('Back', screen_w - 100, 20, 100, 50)
	back_button.on_click = function (self)		
		StateManager:instance():change_state('StageSelect')
	end

	local restart_button = Button('Restart', screen_w - 100 - 80, 20, 100, 50)
	restart_button.on_click = function (b)
		self.play:restart()
	end

	self.buttons:add(restart_button)
	self.buttons:add(back_button)
end)

function PlayStage:exit()
	local ed = EventDispatcher:instance()
	ed:remove('mousepressed', self, self.mousepressed)

	self.buttons:release()
	self.play:release()	
end

function PlayStage:update(dt)
	self.play:update(dt)
end

function PlayStage:draw()	
	self.buttons:draw()
	self.play:draw()
end

function PlayStage:mousepressed(x, y, button)
	if self.play:is_end() then
		if button == 'l' then
			if self.play:succeed() then
				self.stage:pass()
				StateManager:instance():change_state('StageSelect')
			else
				self.play:restart()
			end
		end
	end
end
