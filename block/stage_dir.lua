require('button')
require('stage_loader')
require('log')

local BW, BH, COL, ROW = 140, 140, 4, 4

StageButton = class(Button, function (self, stage, x, y, w, h)
	Button.init(self, stage.name, x, y, w, h)
	self.stage = stage	
end)

function StageButton:mousemoved(x, y)
	if self.pressed then
		self:set_pos(self.ox + x - self.mx, self.oy + y - self.my)		
	else
   		self.hover = self:test_point(x, y)
   	end
end

function StageButton:mousepressed(x, y)
   	self.pressed = self.hover
   	if self.pressed then
   		self:on_pressed()
   		self.mx, self.my = x, y
   		self.ox, self.oy = self.x, self.y
   	end
end

function StageButton:mousereleased(x, y)   
   	if self.pressed and self.hover then
      	if self.x == self.ox and self.y == self.oy then
      		self:on_click()
      	else
      		self:set_pos(self.ox, self.oy)
      		self:on_move_end(x, y)
      	end
   	end

   	self.pressed = false
end

function StageButton:draw()
	if self.visible then
		if self.pressed then
			love.graphics.setColor(255,202,136)
			love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
		end
		self.stage.board.draw()
	end
end

function StageButton:set_pos(x, y)
	self.x, self.y = x, y
	self.stage.board.set_pos_and_scale(self.x + BW / 2, self.y + BH / 2, 0.25)
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

StageDir = class(function (self, dir)
	self.buttons = Buttons()
	local stage_files = list_filepath(dir)
	table.sort(stage_files)	
	for _, path in ipairs(stage_files) do
		self:add(path)
	end

	self.visible = true
	self.page_id = 1
	self:update()	
end)

function StageDir:get_select_path()
	return self.selected_button.stage.path
end

function StageDir:remove_select()
	self.buttons:remove(self.selected_button)
	self.selected_button = nil
	self:update()
end

function StageDir:add(path)
	local stage = Stage(path)
	local b = StageButton(stage, 0, 0, BW, BH)
	b.on_click = function (b)
		if self.on_click then
			self:on_click(b)
		end
	end
	b.on_pressed = function (b)
		self.selected_button = b
		print('select', b.text)
	end
	b.on_move_end = function (b, x, y)
		if self.on_move_end then
			self:on_move_end(b, x, y)
		end
	end
	self.buttons:add(b)	
end

function StageDir:update()
	self.row_count = (self.buttons:count() + COL - 1) / COL
	self.max_page = math.floor((self.row_count + ROW - 1) / ROW)
	self:set_page(self.page_id)
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
end

function StageDir:release()
	self.buttons:release()
end

function StageDir:draw()
	if self.visible then
		self.buttons:draw()
		if self.selected_button then
			self.selected_button:draw()
		end
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
