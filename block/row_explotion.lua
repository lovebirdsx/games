require('sound')

row_explotion = {}

local I = 0.1
local ADD0 = 0.8
local ADD1 = 0.9

local FADE_CFG = {
	{t = I * 0, add = ADD0},
	{t = I * 1, add = ADD1},
	{t = I * 2, add = ADD0},
	{t = I * 3, add = ADD1},
	{t = I * 4, add = ADD0},	
}

function row_explotion.create(row_hexs)
	local self = {}
	local passed = 0
	local is_end = false
	local add_color = {FADE_CFG[1].add, FADE_CFG[1].add, 
		FADE_CFG[1].add, 255}

	function self._get_add_color(t)
		local add = 0
		if t == 0 then 
			add = FADE_CFG[1].add
		else
			for i, cfg in ipairs(FADE_CFG) do
				if t < cfg.t then
					local cfg0 = FADE_CFG[i - 1]
					add = cfg0.add + (cfg.add - cfg0.add) * (t - cfg0.t)
					break
				end
			end
		end

		return {add * 255, add * 255, add * 255, 255}
	end

	function self.update(dt)
		if is_end then return end

		passed = passed + dt
		if passed <= FADE_CFG[#FADE_CFG].t then
			add_color = self._get_add_color(passed)
		else
			is_end = true
			if self.on_end_cb then
				self.on_end_cb()
			end
		end
	end

	function self.draw()
		if is_end then return end

		for _, hex in ipairs(row_hexs) do
			hex.draw_c(add_color, add_color[4])
		end
	end

	function self.type()
		return 'row_explotion'
	end

	function self.is_end()
		return is_end
	end

	function self.on_end(cb)
		self.on_end_cb = cb
	end

	return self
end
