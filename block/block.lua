require('hexagon')

block = {}

function block.create(pos_list, id, x, y, scale)
	local self = {x = x or 0, y = y or 0, scale = scale or 1, draw_scale = 1}
	local hexs = {}	

	function self._init()
		for _, p in ipairs(pos_list) do
			local h = hexagon.create(p[1], p[2], id, scale)
			table.insert(hexs, h)
		end
		self._update_hex()
	end

	function self.draw()
		for _, h in ipairs(hexs) do
			h.draw(true)
		end
	end

	function self._update_hex()
		local s = self.scale * self.draw_scale
		for _, h in ipairs(hexs) do
			h.x = self.x + h.rx * hexagon.w / 2 * self.scale
			h.y = self.y + h.ry * hexagon.h / 2 * self.scale
			h.scale = s
		end
	end

	function self.set_pos(x, y)
		self.x, self.y = x, y
		self._update_hex()
	end

	function self.set_scale(scale)
		self.scale = scale
		self._update_hex()
	end

	function self.set_draw_scale(scale)
		self.draw_scale = scale
		self._update_hex()
	end

	function self.test_point(x, y, range)
		for _, h in ipairs(hexs) do
			if h.test_point(x, y, range) then
				return true
			end
		end
		return false
	end

	function self.get_hex_list()
		return hexs
	end

	function self.hex_count()
		return #hexs
	end
	
	self._init()	

	return self
end
