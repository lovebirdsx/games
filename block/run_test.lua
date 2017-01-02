require('state_manager')
require('event_dispatcher')
require('font')
require('test')

local global_print
local text

RunTest = class(State, function (self)
	text = ''
	global_print = print
	print = RunTest.print

	test()

	local ed = EventDispatcher:instance()
	ed:add('mousepressed', self, self.mousepressed)

	self.y = 10
end)

function RunTest.print(...)
	global_print(...)
	text = text .. table.concat({...}, '\t') .. '\n'
end

function RunTest:exit()
	print = global_print
	local ed = EventDispatcher:instance()
	ed:remove('mousepressed', self, self.mousepressed)
end

function RunTest:mousepressed(x, y, button)
	if button == 'wu' then
		self.y = self.y - 50		
	end

	if button == 'wd' then
		self.y = self.y + 50
		if self.y > 0 then self.y = 0 end
	end
end

function RunTest:draw()
	love.graphics.setColor(255, 255, 255, 255)
	font.print('normal', text, 100, self.y)
end
