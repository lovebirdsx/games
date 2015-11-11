require('button')
require('stage_loader')
require('log')

local BW, BH, COL, ROW = 140, 140, 4, 4

StageButton = class(Button, function (self, stage, x, y, w, h)
	Button.init(self, stage.name, x, y, w, h)
	self.stage = stage
end)

function StageButton:draw()
	if self.visible then
		if self.is_selected then
			love.graphics.setColor(255,202,136)
			love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
		end
		self.stage.board.draw()
	end
end

function StageButton:check_load()
	if self.visible then
		self.stage:load()
		self.stage.board.set_pos_and_scale(self.x + BW / 2, self.y + BH / 2, 0.25)
	end
end

function StageButton:show()
	Button.show(self)
	self:check_load()
end

function StageButton:select(bool)
	self.is_selected = bool
end

StageDir = class(function (self, dir)
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
		local b = StageButton(stage, 0, 0, BW, BH)
		b.on_click = function (b)
			self:select_button(b)
		end
		buttons:add(b)
	end

	self.buttons = buttons
	self.stages = stages
	self.visible = true

	self:update_page_count()
	self:set_page(1)
end)

function StageDir:select_button(b)
	if self.selected_button then
		self.selected_button:select(false)
	end
	self.selected_button = b
	b:select(true)
end

function StageDir:get_select_path()
	return self.selected_button.text
end

function StageDir:delete_select()
	-- remove from dir
	

	self.buttons:remove(self.selected_button)
	self.selected_button = nil
	self:update_page_count()
	self:set_page()
end

function StageDir:update_page_count()
	self.row_count = (self.buttons:count() + COL - 1) / COL
	self.max_page = math.floor((self.row_count + ROW - 1) / ROW)
end

function StageDir:set_page(page)	
	if page < 1 then page = self.max_page end
	if page > self.max_page then page = 1 end	

	self.page_id = page	

	for i = 1, self.buttons:count() do
		self.buttons:get_button(i):hide()
	end

	local dw, dh = BW + 15, love.graphics.getHeight() / ROW
	for r = 1, ROW do
		for c = 1, COL do
			local b = self.buttons:get_button((((page - 1) * ROW) + r - 1) * COL + c)
			if b then
				b.x, b.y = 250 + dw * (c - 1), dh * (r - 1)
				b:show()
			end
		end
	end

	local fb = self.buttons:get_button(((page - 1) * ROW) * COL + 1)
	self:select_button(fb)
end

function StageDir:release()
	self.buttons:release()
end

function StageDir:draw()
	if self.visible then
		self.buttons:draw()
		love.graphics.setColor(255, 255, 255)
		font.print('normal', string.format('[%d/%d]', self.page_id, self.max_page), 840, 10)
	end
end

function StageDir:page_up()
	self:set_page(self.page_id - 1)
end

function StageDir:page_down()
	self:set_page(self.page_id + 1)
end

function StageDir:show()
	self.visible = true
	self.buttons:show()
end

function StageDir:hide()
	self.visible = false
	self.buttons:hide()
end
