require('state_manager')

ModeSelect = class(State, function (self)
	self.buttons = Buttons()

	local screen_w = love.graphics.getWidth()
	local bw = 200
	local bh = 100
	local offset = 80
	local y = 250
	local bEndlessPlay = Button('Endless', screen_w / 2 - offset - bw, y, bw, bh)
	local bStagePlay = Button('Puzzle',  screen_w / 2 + offset, y, bw, bh)
	local bEditor = Button('Editor', 350, 400, bw, bh)
	bEndlessPlay.font_type = 'hurge'
	bStagePlay.font_type = 'hurge'
	bEditor.font_type = 'hurge'

	bEndlessPlay.on_click = function ()		
		StateManager:instance():change_state('EndlessPlay')
	end

	bStagePlay.on_click = function ()
		StateManager:instance():change_state('ChapterSelect')
	end

	bEditor.on_click = function ()
		StateManager:instance():change_state('StageFilter')
	end

	self.buttons:add(bEndlessPlay)
	self.buttons:add(bStagePlay)
	self.buttons:add(bEditor)
end)

function ModeSelect:exit()
	self.buttons:release()
end

function ModeSelect:draw()
	self.buttons:draw()
end
