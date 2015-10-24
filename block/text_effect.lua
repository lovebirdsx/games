require('font')

text_effect = {}

local DX = 0
local DY = 50
local T = 0.5

function text_effect.create(text, x, y)
	local self = {}
	local passed = 0
	local draw_x, draw_y = x, y

	function self.update(dt)
		passed = passed + dt
		local progress = (1 - passed / T)
		draw_x = x + DX * progress
		draw_y = y + DY * progress

		if passed > T then
			self.on_end_cb()
		end
	end

	function self.draw()
		love.graphics.setColor(255, 255, 255, 255)
		font.print('hurge', text, draw_x, draw_y)
	end

	function self.on_end(cb)
		self.on_end_cb = cb
	end

	return self
end
