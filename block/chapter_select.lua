require('misc')
require('state_manager')
require('stage_select')
require('button')

local BW = 180
local BH = 180
local BW_OFFSET = 20
local BH_OFFSET = 20
local DRAW_X = (900 - BW * 4 - BW_OFFSET * 3) / 2
local DRAW_Y = 200
local COL_COUNT = 4

ChapterSelect = class(State, function (self)
	self.buttons = Buttons()

	local chapters = list_dirs('chapters')
	table.sort(chapters)
	print(DRAW_X, DRAW_Y)
	for i, name in ipairs(chapters) do
		local r = math.floor((i + COL_COUNT - 1) / COL_COUNT)
		local c = (i % COL_COUNT == 0) and COL_COUNT or (i % COL_COUNT)
		local x = DRAW_X + (c - 1) * (BW_OFFSET + BW)
		local y = DRAW_Y + (r - 1) * (BH_OFFSET + BH)
		local text = string.format('Chapter %d', name)
		local botton = Button(text, x, y, BW, BH)
		print(r, c, x, y, text)
		self.buttons:add(botton)
		botton.on_click = function ()
			local stage_select = StageSelect('chapters/' .. name)
			local sm = StateManager:instance()
			sm:change_state(stage_select)
		end
	end
end)

function ChapterSelect:draw()
	self.buttons:draw()
end

function ChapterSelect:exit()
	self.buttons:release()
end
