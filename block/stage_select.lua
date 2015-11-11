require('stage_loader')
require('state_manager')
require('misc')
require('button')

local BOARD_ORIGIN_W = 600
local BOARD_W, BOARD_H = 160,  160
local BOARD_OFF_X, BOARD_OFF_Y = 20, 20
local COL_COUNT = 4
local BOARD_X = (900 - BOARD_W * COL_COUNT - BOARD_OFF_X * (COL_COUNT - 1)) / 2
local BOARD_Y = 150

BoardButton = class(Button, function (self, stage, x, y, w, h)
	Button.init(self, stage.name, x, y, w, h)
	self.stage = stage
	stage.board.set_pos_and_scale(x + w / 2, y + h / 2, BOARD_W / BOARD_ORIGIN_W)
end)

function BoardButton:draw()
	self.stage.board.draw()
	if not self.stage.is_unlocked then
		love.graphics.setColor(240, 20, 20)
		font.print('big', 'locked', self.x + 50, self.y + 65)
	end
end

local prev_chapter

StageSelect = class(State, function (self, chapter)
	chapter = chapter or prev_chapter
	prev_chapter = chapter

	chapter:check_unlock()

	local buttons = Buttons()
	-- stage buttons
	for i, stage in ipairs(chapter.stages) do
		stage:load()

		local r = math.floor((i + COL_COUNT - 1) / COL_COUNT)
		local c = (i % COL_COUNT == 0) and COL_COUNT or (i % COL_COUNT)
		local x = BOARD_X + (c - 1) * (BOARD_OFF_X + BOARD_W)
		local y = BOARD_Y + (r - 1) * (BOARD_OFF_Y + BOARD_H)
		
		local b = BoardButton(stage, x, y, BOARD_W, BOARD_H)
		b.on_click = function (b)
			if b.stage.is_unlocked then
				StateManager:instance():change_state('PlayStage', b.stage)
			else
				text_effect.create('Stage is locked', 280, 500)
			end
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

function StageSelect:exit()
	self.buttons:release()
end

function StageSelect:draw()
	self.buttons:draw()	
end
