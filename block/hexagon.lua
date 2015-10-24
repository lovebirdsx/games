require('render')

local HEX_COLOR = {
	[0] = {77, 77, 75},		-- no color
	[1] = {255,220,137},	-- color 1
	[2] = {255,137,181},	-- color 2
	[3] = {245,162,11},		-- color 3
	[4] = {137,140,255},	-- color 4
	[5] = {113,224,150},	-- color 5
	[6] = {207,243,129},	-- color 6	
}

hexagon = {w = 59, h = 50, max_id = 6}

function hexagon.create(rx, ry, id, scale, x, y)
	local self = {
		rx = rx,
		ry = ry,
		id = id or 0,
		scale = scale or 1,		
		x = x or 0,
		y = y or 0,
		is_focus = false,
	}

	function self.string()
		return string.format('(%2d,%2d,%2d)', self.rx, self.ry, self.id)	
	end	

	function self.draw(shadow)
		if shadow then
			render.draw_hex_shadow(self.x, self.y, self.scale)
		end		
		self.draw_c(HEX_COLOR[self.id], self.is_focus and 128 or 255)
	end

	function self.draw_c(c, alpha)
		render.draw_hex(c, self.x, self.y, self.scale, alpha)
	end

	function self.test_point(x, y, range)
		range = range or 0.9
		local w = hexagon.w * self.scale * range
		local h = hexagon.h * self.scale * range
		return 	self.x - w / 2 < x and x < self.x + w / 2 and 
				self.y - h / 2 < y and y < self.y + h / 2
	end

	function self.can_locate()
		return self.id == 0 or self.is_focus
	end

	function self.focus(bool)
		self.is_focus = bool
	end

	function self.is_fill()
		return not self.can_locate()
	end

	function self.copy()
		local c = {}
		for k,v in pairs(self) do
			c[k] = v
		end
		return c
	end

	return self
end
