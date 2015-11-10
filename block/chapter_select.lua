require('button')
require('state_manager')
require('chapters')

local BW = 180
local BH = 180
local BW_OFFSET = 20
local BH_OFFSET = 20
local DRAW_X = (900 - BW * 4 - BW_OFFSET * 3) / 2
local DRAW_Y = 200
local COL_COUNT = 4

ChapterButton = class(Button, function(self, text, x, y, w, h, chapter)
	Button.init(self, text, x, y, w, h)
	self.chapter = chapter
end)

ChapterSelect = class(State, function (self)
	self.buttons = Buttons()

	local chapters = Chapters:instance()	
	for i, chapter in ipairs(chapters.chapters) do
		local r = math.floor((i + COL_COUNT - 1) / COL_COUNT)
		local c = (i % COL_COUNT == 0) and COL_COUNT or (i % COL_COUNT)
		local x = DRAW_X + (c - 1) * (BW_OFFSET + BW)
		local y = DRAW_Y + (r - 1) * (BH_OFFSET + BH)
		local text = chapter.name
		local botton = ChapterButton(text, x, y, BW, BH, chapter)
		botton.font_type = 'hurge'
		self.buttons:add(botton)
		botton.on_click = function (b)
			local sm = StateManager:instance()
			sm:change_state('StageSelect', b.chapter)
		end
	end

	-- return button
	local screen_w = love.graphics.getWidth()
	local bReturn = Button('Back', screen_w - 100, 20, 100, 50)
	bReturn.on_click = function ()
		StateManager:instance():change_state('ModeSelect')
	end
	self.buttons:add(bReturn)
end)

function ChapterSelect:draw()
	self.buttons:draw()
end

function ChapterSelect:exit()
	self.buttons:release()
end
