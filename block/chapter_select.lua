require('misc')
require('state_manager')
require('stage_select')
require('button')

ChapterSelect = class(state)

local BW = 180
local BH = 180
local BW_OFFSET = 20
local BH_OFFSET = 20
local DRAW_X = (900 - BW * 4 - BW_OFFSET * 3) / 2
local DRAW_Y = 200
local COL_COUNT = 4

function ChapterSelect:init()
	self.buttons = Buttons:new()

	local chapters = list_dirs('chapters')
	table.sort(chapters)
	for i, name in ipairs(chapters) do
		local r = math.ceil((i + COL_COUNT - 1) / COL_COUNT)
		local c = (i % COL_COUNT == 0) and COL_COUNT or (i % COL_COUNT)
		local x = DRAW_X + c * BW + (c - 1) * BW_OFFSET
		local y = DRAW_Y + r * BH + (r - 1) * BH_OFFSET
		local text = string.format('Chapter %d', name)
		local botton = Button:new(text, x, y, BW, BH)
		self.buttons:add(button)
		botton.on_click = function ()
			local stage_select = StageSelect:new('chapters/' .. name)
			local sm = StateManager:instance()
			sm:change_state(stage_select)
		end
	end
end

function ChapterSelect:enter()
	
end

function ChapterSelect:exit()
	-- body
end

function ChapterSelect:update(dt)
	
end

function ChapterSelect:draw()
	self.buttons:draw()
end

function ChapterSelect:mousepressed(x, y, button)
	self.buttons:mousepressed(x, y)
end

function ChapterSelect:mousemoved(x, y, dx, dy)
	self.buttons:mousemoved(x, y)
end

function ChapterSelect:mousereleased(x, y, button)
	self.buttons:mousereleased(x, y)
end

function ChapterSelect:keypressed(key)
	-- body
end
