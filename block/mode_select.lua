require('state_manager')

ModeSelect = class(State, function (self)
	self.buttons = Buttons()

	local screen_w = love.graphics.getWidth()
	local bw = 200
	local bh = 200
	local offset = 80
	local y = 250
	local bEndlessPlay = Button('Endless', screen_w / 2 - offset - bw, y, bw, bh)
	local bStagePlay = Button('Leves',  screen_w / 2 + offset, y, bw, bh)
	bEndlessPlay.font_type = 'hurge'
	bEndlessPlay.on_click = function ()		
		StateManager:instance():change_state('EndlessPlay')
	end

	bStagePlay.font_type = 'hurge'
	bStagePlay.on_click = function ()
		StateManager:instance():change_state('ChapterSelect')
	end

	self.buttons:add(bEndlessPlay)
	self.buttons:add(bStagePlay)
end)

function ModeSelect:exit()
	self.buttons:release()
end

function ModeSelect:draw()
	self.buttons:draw()
end
