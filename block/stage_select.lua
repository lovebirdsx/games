require('stage')
require('state_manager')
require('misc')

local BOARD_SCALE = 0.3

BoardButton = class(Button, function (self, text, x, y, w, h, board)
	Button(self, text, x, y, w, h)
	self.board = board
end)

function BoardButton:draw()
	
end

StageSelect = class(State, function (self, path)
	self.stages = self:_create_stages(path)
end)

function StageSelect:_load_stage(path)
	local s = love.filesystem.read(path)
	return stage.load_by_str(s)
end

function StageSelect:_create_stages(path)
	local stages = {}
	local files = list_filepath(path)
	table.sort(files)
	for i, file in ipairs(files) do
		stages[i] = self:_load_stage(file)
	end

	return stages
end

function StageSelect:update(dt)
	
end

function StageSelect:draw()
	
end

function StageSelect:mousepressed(x, y, button)
	
end
