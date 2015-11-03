require('render')
require('misc')

-- how to add new hex type
-- 	- add declare
--	- modify hexagon.max_hex
--	- add TYPE in LINEUP_IDS if needed
--	- add draw fun
--	- add draw fun in render.lua
--	- add gen fun in board.lua
--	- map key to gen fun in game.lua
-- 	- add clear respone in board._start_next_line_up_ani()
--	- add new board gen type in stage_gen.lua
--	- add ani if need

-- seq can not be changed
local HEX_SLOT = 0
local HEX_COLOR1 = 1
local HEX_COLOR2 = 2
local HEX_COLOR3 = 3
local HEX_COLOR4 = 4
local HEX_COLOR5 = 5
local HEX_COLOR6 = 6
local HEX_ICING = 7
local HEX_BOMB = 8
local HEX_2ARROW1 = 9
local HEX_2ARROW2 = 10
local HEX_2ARROW3 = 11
local HEX_COLOR1_ROPE = 12
local HEX_COLOR2_ROPE = 13
local HEX_COLOR3_ROPE = 14
local HEX_COLOR4_ROPE = 15
local HEX_COLOR5_ROPE = 16
local HEX_COLOR6_ROPE = 17

hexagon = {w = 59, h = 50, max_color = 6, max_hex = HEX_COLOR6_ROPE,
	HEX_SLOT = HEX_SLOT,
	HEX_COLOR1 = HEX_COLOR1,
	HEX_COLOR2 = HEX_COLOR2,
	HEX_COLOR3 = HEX_COLOR3,
	HEX_COLOR4 = HEX_COLOR4,
	HEX_COLOR5 = HEX_COLOR5,
	HEX_COLOR6 = HEX_COLOR6,
	HEX_ICING = HEX_ICING,
	HEX_BOMB = HEX_BOMB,
	HEX_2ARROW1 = HEX_2ARROW1,
	HEX_2ARROW2 = HEX_2ARROW2,
	HEX_2ARROW3 = HEX_2ARROW3,
	HEX_COLOR1_ROPE = HEX_COLOR1_ROPE,
	HEX_COLOR2_ROPE = HEX_COLOR2_ROPE,
	HEX_COLOR3_ROPE = HEX_COLOR3_ROPE,
	HEX_COLOR4_ROPE = HEX_COLOR4_ROPE,
	HEX_COLOR5_ROPE = HEX_COLOR5_ROPE,
	HEX_COLOR6_ROPE = HEX_COLOR6_ROPE,
}

local HEX_COLOR = {
	[HEX_SLOT] = {77, 77, 75},
	[HEX_COLOR1] = {255,220,137},
	[HEX_COLOR2] = {255,137,181},
	[HEX_COLOR3] = {245,162,11},
	[HEX_COLOR4] = {137,140,255},
	[HEX_COLOR5] = {113,224,150},
	[HEX_COLOR6] = {207,243,129},
	[HEX_2ARROW1] = {255,137,181},
	[HEX_2ARROW2] = {137,140,255},
	[HEX_2ARROW3] = {207,243,129},
}

local ARROW_K = {
	[HEX_2ARROW1] = 0,
	[HEX_2ARROW2] = 2,
	[HEX_2ARROW3] = -2,
}

local LINEUP_IDS = {
	[HEX_COLOR1] = true,
	[HEX_COLOR2] = true,
	[HEX_COLOR3] = true,
	[HEX_COLOR4] = true,
	[HEX_COLOR5] = true,
	[HEX_COLOR6] = true,
	[HEX_BOMB] = true,
	[HEX_2ARROW1] = true,
	[HEX_2ARROW2] = true,
	[HEX_2ARROW3] = true,
	[HEX_COLOR1_ROPE] = true,
	[HEX_COLOR2_ROPE] = true,
	[HEX_COLOR3_ROPE] = true,
	[HEX_COLOR4_ROPE] = true,
	[HEX_COLOR5_ROPE] = true,
	[HEX_COLOR6_ROPE] = true,
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
		kb_hex = {}
	}

	local _draw_funs

	function self._draw_hex_color()
		self.draw_c(HEX_COLOR[self.id], self.is_focus and 128 or 255)
	end

	function self._draw_bomb()
		love.graphics.setColor(77, 77, 75)
		render.draw_hex_slot(x, y, scale)
		love.graphics.setColor(255, 255, 255)
		render.draw_bomb(self.x, self.y, self.scale)
	end

	function self._draw_icing()
		love.graphics.setColor(77, 77, 75)
		render.draw_hex_slot(x, y, scale)
		love.graphics.setColor(255, 255, 255)
		render.draw_icing(self.x, self.y, self.scale)
	end

	function self._draw_2arrow(rotato)
		love.graphics.setColor(77, 77, 75)
		render.draw_hex_slot(x, y, scale)
		love.graphics.setColor(255, 255, 255)
		render.draw_2arrow(self.x, self.y, self.scale, rotato)
	end

	function self._draw_2arrow1()
		self._draw_2arrow(0)
	end

	function self._draw_2arrow2()
		self._draw_2arrow(math.pi / 360 * 120)
	end

	function self._draw_2arrow3()
		self._draw_2arrow(math.pi / 360 * 240)
	end

	function self._draw_hex_rope()
		local color_id = self.id - HEX_COLOR1_ROPE + HEX_COLOR1
		self.draw_c(HEX_COLOR[color_id], 255)
		render.draw_rope(self.x, self.y, self.scale)
	end

	_draw_funs = {
		[HEX_SLOT] = self._draw_hex_color,
		[HEX_COLOR1] = self._draw_hex_color,
		[HEX_COLOR2] = self._draw_hex_color,
		[HEX_COLOR3] = self._draw_hex_color,
		[HEX_COLOR4] = self._draw_hex_color,
		[HEX_COLOR5] = self._draw_hex_color,
		[HEX_COLOR6] = self._draw_hex_color,
		[HEX_ICING] = self._draw_icing,
		[HEX_BOMB] = self._draw_bomb,
		[HEX_2ARROW1] = self._draw_2arrow1,
		[HEX_2ARROW2] = self._draw_2arrow2,
		[HEX_2ARROW3] = self._draw_2arrow3,
		[HEX_COLOR1_ROPE] = self._draw_hex_rope,
		[HEX_COLOR2_ROPE] = self._draw_hex_rope,
		[HEX_COLOR3_ROPE] = self._draw_hex_rope,
		[HEX_COLOR4_ROPE] = self._draw_hex_rope,
		[HEX_COLOR5_ROPE] = self._draw_hex_rope,
		[HEX_COLOR6_ROPE] = self._draw_hex_rope,
	}

	function self.draw(shadow)
		if shadow then
			render.draw_hex_shadow(self.x, self.y, self.scale)
		end
		
		_draw_funs[self.id]()
	end

	function self.draw_c(c, a)
		love.graphics.setColor(c[1], c[2], c[3], a)
		render.draw_hex_color(self.x, self.y, self.scale)
	end

	function self.string()
		return string.format('(%2d,%2d,%2d)', self.rx, self.ry, self.id)	
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
		return LINEUP_IDS[self.id] and true or false
	end

	-- param
	-- 	event is the event type, as fllows:
	--		lineup
	--		bomb_prepare
	--		bomb
	--		lineup_near_by	-- 
	--	result is the hex effected, like:
	-- 		{
	--			{hex=hex1, event=event1},
	--			{hex=hex2, event=event2},
	--		 ...
	--		}	
	function self.on_event(board, event, result)
		self['_on_event_' .. event](board, result)
		return result
	end

	function self._on_event_lineup(board, result)
		if HEX_COLOR1 <= self.id and self.id <= HEX_COLOR6 then			
			self.id = HEX_SLOT			
			for _, h in ipairs(self.nearby_hex) do
				if h.id == HEX_ICING then
					result[#result + 1] = {hex = h, event='lineup_nearby'}
				end
			end
		elseif self.id == HEX_BOMB then
			result[#result + 1] = {hex = self, event='bomb_prepare'}
		elseif HEX_2ARROW1 <= self.id and self.id <= HEX_2ARROW3 then
			result[#result + 1] = {hex = self, event='bomb_prepare'}
		elseif HEX_COLOR1_ROPE <= self.id and self.id <= HEX_COLOR6_ROPE then
			self.id = self.id - HEX_COLOR1_ROPE + HEX_COLOR1			
		end
	end

	function self._on_event_bomb_prepare(board, result)
		if self.id == HEX_BOMB then
			self.id = HEX_SLOT
			for i, h in ipairs(self.nearby_hex) do
				if h.id ~= HEX_SLOT then
					result[#result + 1] = {hex = h, event='bomb'}
				end
			end
		elseif HEX_2ARROW1 <= self.id and self.id <= HEX_2ARROW3 then
			local k = ARROW_K[self.id]
			self.id = HEX_SLOT
			for i, h in ipairs(self.kb_hex[k]) do
				if h.id ~= HEX_SLOT then
					result[#result + 1] = {hex = h, event='bomb'}
				end
			end
		end
	end

	function self._on_event_lineup_nearby(board, result)
		if self.id == HEX_ICING then
			self.id = HEX_SLOT
		end
	end

	function self._on_event_bomb(board, result)
		if HEX_COLOR1 <= self.id and self.id <= HEX_COLOR6 then	
			self.id = HEX_SLOT
		elseif self.id == HEX_BOMB then
			result[#result + 1] = {hex = self, event='bomb_prepare'}
		elseif HEX_2ARROW1 <= self.id and self.id <= HEX_2ARROW3 then
			result[#result + 1] = {hex = self, event='bomb_prepare'}
		elseif self.id == HEX_ICING then
			self.id = HEX_SLOT
		end
	end

	function self.get_kb_center()
		assert(HEX_2ARROW1 <= self.id and self.id <= HEX_2ARROW3)
		local hexs = self.kb_hex[ARROW_K[self.id]]
		local tx, ty = 0, 0
		for _, h in ipairs(hexs) do
			tx = tx + h.x
			ty = ty + h.y
		end
		return tx / #hexs, ty / #hexs
	end

	function self.get_kb_count()
		assert(HEX_2ARROW1 <= self.id and self.id <= HEX_2ARROW3)
		local hexs = self.kb_hex[ARROW_K[self.id]]
		return #hexs
	end
	
	return self
end
