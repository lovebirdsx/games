require('render')

local SLOT = 0
local COLOR1, COLOR2, COLOR3, COLOR4, COLOR5, COLOR6 = 1,2,3,4,5,6
local ICING = 7

local HEX_COLOR = {
	[SLOT] = {77, 77, 75},
	[COLOR1] = {255,220,137},
	[COLOR2] = {255,137,181},
	[COLOR3] = {245,162,11},
	[COLOR4] = {137,140,255},
	[COLOR5] = {113,224,150},
	[COLOR6] = {207,243,129},
	[ICING] = {255,255,255},
}

local DRAW_FUN = {
	[SLOT] = render.draw_hex_slot,
	[COLOR1] = render.draw_hex_color,
	[COLOR2] = render.draw_hex_color,
	[COLOR3] = render.draw_hex_color,
	[COLOR4] = render.draw_hex_color,
	[COLOR5] = render.draw_hex_color,
	[COLOR6] = render.draw_hex_color,
	[ICING] = render.draw_icing,
}

hexagon = {w = 59, h = 50, max_id = 6,
	type_slot = SLOT,
	type_color1 = COLOR1,
	type_color2 = COLOR2,
	type_color3 = COLOR3,
	type_color4 = COLOR4,
	type_color5 = COLOR5,
	type_color6 = COLOR6,
	type_icing = ICING,
}

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

	function self.draw_c(c, a)
		love.graphics.setColor(c[1], c[2], c[3], a)
		DRAW_FUN[self.id](self.x, self.y, self.scale)
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
