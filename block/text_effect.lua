require('font')

text_effect = {}

local DX = 0
local DY = 50
local T = 0.5

text_effect_mgr = {}
local anis = {}

function text_effect_mgr.update(dt)
	local remove = {}
	for _, ani in ipairs(anis) do
		ani.update(dt)
		if ani.is_end then
			remove[#remove + 1] = ani
		end
	end

	for _, ani in ipairs(remove) do
		text_effect_mgr.remove(ani)
	end
end

function text_effect_mgr.draw()
	for _, ani in ipairs(anis) do
		ani.draw()
	end
end

function text_effect_mgr.add(eff_ani)
	anis[#anis + 1] = eff_ani
end

function text_effect_mgr.remove(eff_ani)
	for i, ani in ipairs(anis) do
		if eff_ani == ani then
			table.remove(anis, i)
			break
		end
	end
end

function text_effect.create(text, x, y)
	local self = {}
	local passed = 0
	local draw_x, draw_y = x, y
	local is_end = false

	function self.update(dt)
		if is_end then return end

		passed = passed + dt
		local progress = (1 - passed / T)
		draw_x = x + DX * progress
		draw_y = y + DY * progress

		if passed > T then
			self.is_end = true
		end
	end

	function self.draw()
		if is_end then return end

		love.graphics.setColor(255, 255, 255, 255)
		font.print('hurge', text, draw_x, draw_y)
	end

	function self.on_end(cb)
		self.on_end_cb = cb
	end

	text_effect_mgr.add(self)

	return self
end
