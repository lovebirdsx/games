require('stage')
require('state_manager')
require('misc')
require('button')

local BOARD_ORIGIN_W = 600
local BOARD_W, BOARD_H = 160,  160
local BOARD_OFF_X, BOARD_OFF_Y = 20, 20
local COL_COUNT = 4
local BOARD_X = (900 - BOARD_W * COL_COUNT - BOARD_OFF_X * (COL_COUNT - 1)) / 2
local BOARD_Y = 150

BoardButton = class(Button, function (self, text, x, y, w, h, board)
	Button.init(self, text, x, y, w, h)
	self.board = board
	board.set_pos_and_scale(x + w / 2, y + h / 2, BOARD_W / BOARD_ORIGIN_W)
end)

function BoardButton:draw()
	self.board.draw()
end

local prev_path

StageSelect = class(State, function (self, path)
	path = path or prev_path
	prev_path = path
	self.stages = self:create_stages(path)
	local buttons = Buttons()

	-- stage buttons
	for i, s in ipairs(self.stages) do
		local r = math.floor((i + COL_COUNT - 1) / COL_COUNT)
		local c = (i % COL_COUNT == 0) and COL_COUNT or (i % COL_COUNT)
		local x = BOARD_X + (c - 1) * (BOARD_OFF_X + BOARD_W)
		local y = BOARD_Y + (r - 1) * (BOARD_OFF_Y + BOARD_H)
		local b = BoardButton(s.path, x, y, BOARD_W, BOARD_H, s.board)
		b.on_click = function (self)			
			StateManager:instance():change_state('StagePlay', self.text)
		end		
		buttons:add(b)
	end

	-- return button
	local screen_w = love.graphics.getWidth()
	local bReturn = Button('Back', screen_w - 100, 20, 100, 50)
	bReturn.on_click = function ()
		StateManager:instance():change_state('ChapterSelect')
	end
	buttons:add(bReturn)

	self.buttons = buttons
end)

function StageSelect:load_stage(path)	
	local board = stage.load(path)
	return {board = board, path = path}
end

function StageSelect:create_stages(path)
	local stages = {}
	local files = list_filepath(path)
	table.sort(files)
	for i, file in ipairs(files) do
		stages[i] = self:load_stage(file)
	end

	return stages
end

function StageSelect:exit()
	self.buttons:release()
end

function StageSelect:draw()
	self.buttons:draw()	
end
