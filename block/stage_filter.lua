require('stage_loader')
require('state_manager')
require('misc')
require('button')

local BOARD_ORIGIN_W = 600
local BOARD_W, BOARD_H = 160,  160
local BOARD_OFF_X, BOARD_OFF_Y = 20, 20
local COL_COUNT = 4
local ROW_COUNT = 3
local BOARD_X = (900 - BOARD_W * COL_COUNT - BOARD_OFF_X * (COL_COUNT - 1)) / 2
local BOARD_Y = 150

StageBotton = class(Button, function (self, stage, x, y, w, h)
	Button.init(self, stage.name, x, y, w, h)
	self.stage = stage
	if self:is_in_screen() then
		stage:load()
		stage.board.set_pos_and_scale(x + w / 2, y + h / 2, BOARD_W / BOARD_ORIGIN_W)
	end
end)

function StageBotton:draw()
	if self:is_in_screen() then
		self.stage.board.draw()
	end
end

function StageBotton:is_in_screen()
	return -BOARD_H < self.y and self.y < 600
end

Stages = class(function (self)
	buttons = Buttons()
	local stage_files = list_filepath(dir)
	table.sort(stage_files)

	stages = {}
	for _, path in ipairs(stage_files) do
		local stage = Stage(path)
		stages[#stages + 1] = stage		
	end

	-- stage buttons
	for i, stage in ipairs(stages) do
		local r = math.floor((i + COL_COUNT - 1) / COL_COUNT)
		local c = (i % COL_COUNT == 0) and COL_COUNT or (i % COL_COUNT)
		local x = BOARD_X + (c - 1) * (BOARD_OFF_X + BOARD_W)
		local y = BOARD_Y + (r - 1) * (BOARD_OFF_Y + BOARD_H)		
		local b = StageBotton(stage, x, y, BOARD_W, BOARD_H)
		b.on_click = function (b)
			if b.stage.is_unlocked then
				StateManager:instance():change_state('StagePlay', b.stage)			
			end
		end
		buttons:add(b)
	end

	self.buttons = buttons
	self.stages = stages

	self:set_page(1)
end)

function Stages:set_page(id)
	self.page_id = id

end

function Stages:release()
	self.buttons:release()
end

function Stages:draw()
	self.buttons:draw()
end

function Stages:page_up()
	self:move_page(-1)
end

function Stages:page_down()
	self:move_page(1)
end

function Stages:move_page(direction)
	
end

StageSelect = class(State, function (self)
	local buttons = Buttons()

	-- return button
	local screen_w = love.graphics.getWidth()
	local bReturn = Button('Back', screen_w - 100, 20, 100, 50)
	bReturn.on_click = function ()
		StateManager:instance():change_state('ModeSelect')
	end
	buttons:add(bReturn)

	self.buttons = buttons
	self.stages = Stages()
end)

function StageSelect:exit()
	self.buttons:release()
	self.stages:release()
end

function StageSelect:draw()
	self.buttons:draw()
	self.stages:draw()
end
