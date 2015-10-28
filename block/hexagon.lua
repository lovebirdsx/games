require('render')

local HEX_SLOT = 0
local HEX_COLOR1 = 1
local HEX_COLOR2 = 2
local HEX_COLOR3 = 3
local HEX_COLOR4 = 4
local HEX_COLOR5 = 5
local HEX_COLOR6 = 6
local HEX_ICING = 7
local HEX_BOMB = 8

hexagon = {w = 59, h = 50, max_color = 6,
	HEX_SLOT = HEX_SLOT,
	HEX_COLOR1 = HEX_COLOR1,
	HEX_COLOR2 = HEX_COLOR2,
	HEX_COLOR3 = HEX_COLOR3,
	HEX_COLOR4 = HEX_COLOR4,
	HEX_COLOR5 = HEX_COLOR5,
	HEX_COLOR6 = HEX_COLOR6,
	HEX_ICING = HEX_ICING,
	HEX_BOMB = HEX_BOMB,
}

local HEX_COLOR = {
	[HEX_SLOT] = {77, 77, 75},
	[HEX_COLOR1] = {255,220,137},
	[HEX_COLOR2] = {255,137,181},
	[HEX_COLOR3] = {245,162,11},
	[HEX_COLOR4] = {137,140,255},
	[HEX_COLOR5] = {113,224,150},
	[HEX_COLOR6] = {207,243,129},
	[HEX_ICING] = {255,255,255},
	[HEX_BOMB] = {255,255,255},
}

local DRAW_FUN = {
	[HEX_SLOT] = render.draw_hex_slot,
	[HEX_COLOR1] = render.draw_hex_color,
	[HEX_COLOR2] = render.draw_hex_color,
	[HEX_COLOR3] = render.draw_hex_color,
	[HEX_COLOR4] = render.draw_hex_color,
	[HEX_COLOR5] = render.draw_hex_color,
	[HEX_COLOR6] = render.draw_hex_color,
	[HEX_ICING] = render.draw_icing,
	[HEX_BOMB] = render.draw_bomb,
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
		nearby_hex = nil,
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

	function self.is_empty()
		return self.id == HEX_SLOT
	end

	function self.can_line_up()
		return (HEX_COLOR1 <= self.id and self.id <= HEX_COLOR6)
			or self.id == HEX_BOMB
	end

	function self.on_lineup(result, depth)
		if HEX_COLOR1 <= self.id and self.id <= HEX_COLOR6 then
			if result then
				table.insert(result, {self, self.id, depth})
				self.id = HEX_SLOT
				
				for _, h in ipairs(self.nearby_hex) do
					h.on_lineup_nearby(result, depth)
				end
			else
				self.id = HEX_SLOT
			end
		elseif self.id == HEX_BOMB then
			if result then 
				table.insert(result, {self, self.id, depth})
				self.id = HEX_SLOT
				for i, h in ipairs(self.nearby_hex) do
					h.on_bomb(result, depth + 1)
				end
			else
				self.id = HEX_SLOT
			end
		end
	end

	function self.on_bomb(result, depth)
		if self.id ~= HEX_SLOT then
			if result then
				table.insert(result, {self, self.id, depth})
				if self.id == HEX_BOMB then
					self.id = HEX_SLOT
					for i, h in ipairs(self.nearby_hex) do
						h.on_bomb(result, depth + 1)
					end
				else				
					self.id = HEX_SLOT
				end
			else
				self.id = HEX_SLOT
			end
		end
	end

	function self.on_lineup_nearby(result, depth)
		if self.id == HEX_ICING then
			if result then
				table.insert(result, {self, self.id, depth})
			end
			self.id = HEX_SLOT
		end
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
