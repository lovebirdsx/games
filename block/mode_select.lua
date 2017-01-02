require('state_manager')
require('leader_board_cl')
require('game_saver')
require('event_dispatcher')
require('config')

ModeSelect = class(State, function (self)
	self.buttons = Buttons()

	local endless_button = 	Button('Endless', 500, 150, 200, 100)
	local stage_button = 	Button('Puzzle',  500, 300, 200, 100)
	local edit_button = 	Button('Editor',  800, 10, 100, 50)
	endless_button.font_type = 'hurge'
	stage_button.font_type = 'hurge'	

	endless_button.on_click = function ()		
		StateManager:instance():change_state('EndlessPlay')
	end

	stage_button.on_click = function ()
		StateManager:instance():change_state('ChapterSelect')
	end

	edit_button.on_click = function ()
		StateManager:instance():change_state('StageFilter')
	end

	self.buttons:add(endless_button)
	self.buttons:add(stage_button)
	self.buttons:add(edit_button)
	edit_button:hide()
	self.editor_visible = false
	self.edit_button = edit_button

	self:load()
	if self.editor_visible then
		self.edit_button:show()
	end

	local ed = EventDispatcher:instance()
	ed:add('keypressed', self, self.keypressed)
end)

function ModeSelect:load()
	local cfg = GameSaver:instance():get('ModeSelect')
	if cfg then
		self.editor_visible = cfg.editor_visible
	end
end

function ModeSelect:save()	
	local gs = GameSaver:instance()
	gs:set('ModeSelect', {editor_visible = self.editor_visible})
end

function ModeSelect:keypressed(key)
	if key == 'f4' then
		self.editor_visible = not self.editor_visible
		if self.editor_visible then
			self.edit_button:show()
		else
			self.edit_button:hide()
		end
	end
end

function ModeSelect:update(dt)
	LeaderBoardClient:instance():update(dt)
end

function ModeSelect:exit()
	self:save()
	local ed = EventDispatcher:instance()
	ed:remove('keypressed', self, self.keypressed)
	self.buttons:release()
end

function ModeSelect:draw()
	self.buttons:draw()
	LeaderBoardClient:instance():draw()
end
