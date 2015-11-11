require('state_manager')
require('misc')
require('event_dispatcher')
require('stage_dir')
require('stage_play')
require('stage')
require('log')

local dirs = {
	'stages',
	'backup',
	'chapters/1',
	'chapters/2',
	'chapters/3',
	'chapters/4',
	'chapters/5',
	'chapters/6',
	'chapters/7',
	'chapters/8',
}

StageFilterButton = class(Button, function (self, text, x, y, w, h)
	Button.init(self, text, x, y, w, h)	
	self.is_selected = false
end)

function StageFilterButton:draw()
	if self.is_selected then
		love.graphics.setColor(255,202,136)
		love.graphics.rectangle('line', self.x - 20, self.y - 10, self.width, self.height)
	end

	Button.draw(self)
end

function StageFilterButton:select(bool)
	self.is_selected = bool
end

StageFilter = class(State, function (self)
	local buttons = Buttons()

	-- return button	
	local b_back = Button('Back', 50, 20, 100, 50)
	b_back.on_click = function ()
		if self.play then
			self:play_select_stage_end()
		else
			StateManager:instance():change_state('ModeSelect')
		end
	end
	buttons:add(b_back)

	-- dir buttons
	local dir_buttons = {}
	for i, dir in ipairs(dirs) do
		local b = StageFilterButton(dir, 50, 50 + i * 50, 160, 50)
		b.on_click = function (button)
			self:on_click(button)
		end		
		buttons:add(b)
		dir_buttons[#dir_buttons + 1] = b
	end

	local stages_dirs = {}
	for i, dir in ipairs(dirs) do
		local stages_dir = StageDir(dir)
		stages_dir:hide()
		stages_dirs[dir] = stages_dir
	end

	self.buttons = buttons
	self.stages_dirs = stages_dirs
	self.backup_dir = stages_dirs['backup']	
	self.dir_buttons = dir_buttons

	local ed = EventDispatcher:instance()
   	ed:add('keypressed', self, self.keypressed)
   	ed:add('mousepressed', self, self.mousepressed)

   	self:on_click(dir_buttons[1])
end)

function StageFilter:exit()
	self.buttons:release()
	for _, stages_dir in pairs(self.stages_dirs) do
		stages_dir:release()
	end
	local ed = EventDispatcher:instance()
	ed:remove('keypressed', self, self.keypressed)
	ed:remove('mousepressed', self, self.mousepressed)
end

function StageFilter:select_dir(stages_dir)
	if self.play then
		self:play_select_stage_end()
	end

	if self.selected_stages_dir then
		self.selected_stages_dir:hide()		
	end

	self.selected_stages_dir = stages_dir
	stages_dir:show()	
end

function StageFilter:select_dir_by_name(dir)
	local stages_dir = self.stages_dirs[dir]
	self:select_dir(stages_dir)
end

function StageFilter:on_click(b)
	if self.selected_button then		
		self.selected_button:select(false)
	end

	b:select(true)
	self.selected_button = b
	self:select_dir_by_name(b.text)
end

function StageFilter:page_up()
	self.selected_stages_dir:page_up()
end

function StageFilter:page_down()
	self.selected_stages_dir:page_down()
end

function StageFilter:delete_select_stage()
	if self.selected_stages_dir ~= self.backup_dir then
		local from = self.selected_stages_dir:get_select_path()	
		local to = 'backup/' .. get_file_name_by_path(from)
		info('StageFilter: delete %s (%s)', from, to)
		copy_file(from, to)
		self.selected_stages_dir:remove_select()
		self.backup_dir:add(to)
		self.backup_dir:update()
	else
		local from = self.selected_stages_dir:get_select_path()
		self.selected_stages_dir:remove_select()
		os.remove(from)
	end

	if self.play then
		self:play_select_stage_end()
	end
end

function StageFilter:play_select_stage()
	if self.play then return end

	local path = self.selected_stages_dir:get_select_path()
	local stage = Stage(path)
	local play = StagePlay(stage)
	play:set_pos_and_scale(450, 300, 0.8)
	self.play = play	

	self.selected_stages_dir:hide()
end

function StageFilter:play_select_stage_end()
	self.play:release()
	self.play = nil
	self.selected_stages_dir:show()
end

local KEY_FUNS = {
	['up'] 		= StageFilter.page_up,
	['w'] 		= StageFilter.page_up,
	['down'] 	= StageFilter.page_down,
	['s'] 		= StageFilter.page_down,
	['delete']	= StageFilter.delete_select_stage,
	['return']	= StageFilter.play_select_stage,
	[' ']	= StageFilter.play_select_stage,
}

function StageFilter:keypressed(key)
	local f = KEY_FUNS[key]
	if f then f(self) end
end

function StageFilter:mousepressed(x, y, b)
	if b == 'r' then
		if self.play then
			self.play:restart()
		else
			self:play_select_stage()
		end
	end
end

function StageFilter:update(dt)
	if self.play then
		self.play:update(dt)
	end
end

function StageFilter:draw()
	self.buttons:draw()
	self.selected_stages_dir:draw()

	if self.play then
		self.play:draw()
	end
end
