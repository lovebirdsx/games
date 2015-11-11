require('state_manager')
require('misc')
require('event_dispatcher')
require('stage_dir')

local dirs = {
	'stages',
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
		StateManager:instance():change_state('ModeSelect')
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
	self.dir_buttons = dir_buttons

	local ed = EventDispatcher:instance()
   	ed:add('keypressed', self, self.keypressed)

   	self:on_click(dir_buttons[1])
end)

function StageFilter:exit()
	self.buttons:release()
	for _, stages_dir in pairs(self.stages_dirs) do
		stages_dir:release()
	end
	local ed = EventDispatcher:instance()
	ed:remove('keypressed', self, self.keypressed)
end

function StageFilter:select_dir(stages_dir)
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
	
end

local KEY_FUNS = {
	['up'] 		= StageFilter.page_up,
	['w'] 		= StageFilter.page_up,
	['down'] 	= StageFilter.page_down,
	['s'] 		= StageFilter.page_down,
}

function StageFilter:keypressed(key)
	local f = KEY_FUNS[key]
	if f then f(self) end
end

function StageFilter:draw()
	self.buttons:draw()
	self.selected_stages_dir:draw()
end
