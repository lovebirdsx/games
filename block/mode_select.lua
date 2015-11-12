require('state_manager')
require('leader_board_cl')
require('config')

ModeSelect = class(State, function (self)
	self.buttons = Buttons()

	local bEndlessPlay = 	Button('Endless', 500, 150, 200, 100)
	local bStagePlay = 		Button('Puzzle',  500, 300, 200, 100)
	local bEditor = 		Button('Editor',  500, 450, 200, 100)
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

	self.lead_board_records = self:get_leadboard_records()
end)

function ModeSelect:get_leadboard_records()
	local cl = LeaderBoardClient(config.sv_addr, config.port)
	return cl:get_all()
end

function ModeSelect:exit()
	self.buttons:release()
end

function ModeSelect:draw_leadboard()
	if not self.lead_board_records then return end

	local str_t = {}
	for i,v in ipairs(self.lead_board_records) do
		str_t[i] = string.format('%16s%16g', v.player, v.score)
	end

	font.print('hurge', 'Leader Board', 20, 80)
	font.print('big', table.concat(str_t, '\n'), 20, 150)
end

function ModeSelect:draw()
	self:draw_leadboard()
	self.buttons:draw()
end
