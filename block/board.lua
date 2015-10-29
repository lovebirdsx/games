require('hexagon')
require('misc')
require('row_ani')
require('icing_ani')
require('bomb_ani')

board = {}

function board.create(s, x, y)
	local self = {}
	self._hexagons = nil
	self._size = 0
	self._x = 0
	self._y = 0
	self._line_up = nil
	self._line_up_count = 0
	self._kb_hex = nil
	self._hex_count = 0
	self._empty_hex_count = 0
	self._lineup_ani_objs = {}
	self._is_lineup_ani_end = true

	function self.print()
		for k, r in pairs(self._kb_hex) do
			for b, hexs in pairs(r) do
				io.write(k .. ',' .. b .. ':')
				for _, h in ipairs(hexs) do
					io.write(h.string())
				end
				io.write('\n')
			end
		end
	end

	function self.excel_string()
		local strs = {}
		self.foreach_hex(function (h)
			if not h.can_locate() then
				table.insert(strs, string.format('(%d,%d,%d)', h.rx, h.ry, h.id))
			end
		end)

		return table.concat(strs, ';')
	end

	function self.apply_excel_string(str)
		-- todo
	end

	function self.print_line_up()
		for k, r in pairs(self._line_up) do
			for b, v in pairs(r) do
				print(string.format('[%2d,%2d]=%s', k, b, v))
			end
		end
	end

	function self.print_kb()
		for k, r in pairs(self._kb_hex) do
			for b, hexs in pairs(r) do
				io.write(string.format(
					'[%2d,%2d,%5s]=', k, b, self._is_line_up(k, b)))
				for _, h in ipairs(hexs) do
					io.write(h.string())
				end
				io.write('\n')
			end
		end
	end

	function self._expand_init(hex, n)
		if n == 1 then return end

		local ids = {{-1,2},{1,2},{-2,0},{2,0},{-1,-2},{1,-2}}
		for _, id in ipairs(ids) do				
			local r, c = hex.rx + id[1], hex.ry + id[2]
			
			if not self._hexagons[r][c] then
				local hx = self._x + hexagon.w / 2 * r
				local hy = self._y + hexagon.h / 2 * c
				self._hexagons[r][c] = hexagon.create(r, c, 0, 1, hx, hy)			
			end

			self._expand_init(self._hexagons[r][c], n - 1)
		end
	end

	function self._expand_init_kb(h1, n)
		if n == 0 then return end
		local ids = {{-1,2},{1,2},{-2,0},{2,0},{-1,-2},{1,-2}}
		for _, id in ipairs(ids) do				
			local rx, ry = h1.rx + id[1], h1.ry + id[2]		
			if self._hexagons[rx] and self._hexagons[rx][ry] then
				local h2 = self._hexagons[rx][ry]
				local k, b = self._get_kb(h1, h2)
				if not self._kb_hex[k] then
					self._kb_hex[k] = {}
				end

				if not self._kb_hex[k][b] then
					self._kb_hex[k][b] = self._get_hexs_by_kb(k, b)
				end

				self._expand_init_kb(h2, n - 1)
			end		
		end
	end

	function self._init_nearby_hex()
		if n == 0  then return end
		local ids = {{-1,2},{1,2},{-2,0},{2,0},{-1,-2},{1,-2}}
		
		self.foreach_hex(function (h)
			local nearby_hex = {}
			for _, id in ipairs(ids) do
				local rx, ry = h.rx + id[1], h.ry + id[2]
				local h0 = self.get_hex(rx, ry)
				if h0 then
					table.insert(nearby_hex, h0)			
				end
			end
			h.nearby_hex = nearby_hex
		end)
		
	end

	function self.init(s, x, y)
		self._size = s or 5
		self._x = x or 300
		self._y = y or 300

		self._hexagons = {}
		for i=-(self._size-1)*2, (self._size-1)*2 do
			self._hexagons[i] = {}
		end

		local hex_center = hexagon.create(0, 0, 0, 1, self._x, self._y)
		self._hexagons[0][0] = hex_center
		self._expand_init(hex_center, self._size)
		self.foreach_hex(function (h)
			self._hex_count = self._hex_count + 1
		end)
		self._empty_hex_count = self._hex_count

		self._kb_hex = {}
		self._expand_init_kb(hex_center, self._size)
		self._line_up = {}
		for k, r in pairs(self._kb_hex) do
			self._line_up[k] = {}
			for b, hexs in pairs(r) do
				self._line_up[k][b] = false
			end
		end

		self._init_nearby_hex()
	end
	
	function self.gen_snapshot()
		local snapshot = {}
		for rid, r in pairs(self._hexagons) do
			local sr = {}
			for cid, h in pairs(r) do
				sr[cid] = h.id
			end
			snapshot[rid] = sr
		end
		return snapshot
	end

	function self.apply_snapshot(s)
		for rid, r in pairs(s) do
			for cid, id in pairs(r) do
				self._hexagons[rid][cid].id = id
			end
		end

		self._update_line_up()
	end

	function self.foreach_hex(f, ...)
		for _, r in pairs(self._hexagons) do
			for _, h in pairs(r) do
				f(h, ...)
			end		
		end
	end

	function self.get_hex_by_pos(x, y)
		for _, r in pairs(self._hexagons) do
			for _, h in pairs(r) do
				if h.test_point(x, y) then
					return h
				end
			end
		end

		return nil
	end

	function self.can_locate(b)
		local center_hex = self.get_hex_by_pos(b.x, b.y)
		if not center_hex then
			return false
		else
			return self.can_locate_by_rx_ry(b, center_hex.rx, center_hex.ry)
		end
	end

	function self.can_locate_by_rx_ry(b, rx, ry)
		local hex_list = b.get_hex_list()
		for _, h in ipairs(hex_list) do
			local bh = self.get_hex(rx + h.rx, ry + h.ry)
			if not bh or not bh.can_locate() then
				return false
			end
		end
		return true
	end

	function self.locate_by_rx_ry(b, rx, ry)
		local hex_list = b.get_hex_list()
		for _, h in ipairs(hex_list) do
			local bh = self.get_hex(rx + h.rx, ry + h.ry)
			bh.id = h.id
			bh.focus(false)
		end

		self._update_line_up()
	end

	function self.undo_locate(b, rx, ry)
		local hex_list = b.get_hex_list()
		for _, h in ipairs(hex_list) do
			local bh = self.get_hex(rx + h.rx, ry + h.ry)
			bh.id = 0
		end

		self._update_line_up()		
	end

	function self.get_hex(rx, ry)
		if not self._hexagons[rx] then 
			return nil
		else
			return self._hexagons[rx][ry]
		end

	end

	function self.set_hex(rx, ry, id)
		self._hexagons[rx][ry].id = id
	end

	function self.can_locate_any(b)
		local result = false
		self.foreach_hex(function (h)
			if h.can_locate() then
				for _, h2 in ipairs(b.get_hex_list()) do
					local rx = h.rx + h2.rx
					local ry = h.ry + h2.ry
					local h1 = self.get_hex(rx, ry)
					if not h1 or not h1.can_locate() then
						return
					end
				end
				result = true
			end
		end)
		return result
	end

	function self.focus(b)
		local hex_list = b.get_hex_list()
		for _, h in ipairs(hex_list) do
			local bh = self.get_hex_by_pos(h.x, h.y)
			bh.id = h.id
			bh.focus(true)
		end
	end

	function self.unfocus()
		self.foreach_hex(function (h)
			if h.is_focus then
				h.focus(false)
				h.id = 0
			end
		end)
	end

	function self.refresh()
		self.foreach_hex(function (h)
			h.id = 0
		end)		
	end

	function self.draw()
		self.foreach_hex(function (h)
			h.draw()
		end)

		for _, obj in ipairs(self._lineup_ani_objs) do
			obj.draw()
		end
	end

	function self.update(dt)
		if not self._is_lineup_ani_end then
			local obj_to_remove = {}
			for _, obj in ipairs(self._lineup_ani_objs) do
				obj.update(dt)
				if obj.is_end() then
					table.insert(obj_to_remove, obj)
				end
			end

			for _, obj in ipairs(obj_to_remove) do
				for i, obj0 in ipairs(self._lineup_ani_objs) do
					if obj0 == obj then
						table.remove(self._lineup_ani_objs, i)
						break
					end
				end
			end

			if #self._lineup_ani_objs <= 0 then
				self._start_next_lineup_ani()
			end
		end
	end

	function self._get_kb(h1, h2)
		local k = (h1.ry - h2.ry) / (h1.rx - h2.rx)
		local b = h1.ry - k * h1.rx
		return k, b
	end

	function self._get_hexs_by_kb(k, b)
		local hexs = {}
		self.foreach_hex(function (h)
			if h.ry == h.rx * k + b then
				table.insert(hexs, h)
			end
		end)
		return hexs
	end

	function self._is_line_up(k, b)
		local hexs = self._kb_hex[k][b]
		assert(hexs)
		for _, h in ipairs(hexs) do
			if not h.can_line_up() then
				return false
			end
		end
		return true
	end

	function self._update_line_up()
		local count = 0
		for k, r in pairs(self._line_up) do
			for b, v in pairs(r) do
				if self._is_line_up(k, b) then
					self._line_up[k][b] = true
					count = count + 1
				else
					self._line_up[k][b] = false
				end
			end
		end
		self._line_up_count = count
	end

	function self._update_empty_hex_count()
		local count = 0
		self.foreach_hex(function (h)
			if h.can_locate() then
				count = count + 1
			end
		end)
		self._empty_hex_count = count
	end

	function self.can_line_up()
		return self._line_up_count > 0
	end

	function self.lineup()
		local rows = self.get_lineup_rows()
		local depth = 0
		local result = {}
		local event_result = {}
		while true do			
			local depth_result = {}
			local next_step_event = {}
			for _, r in ipairs(event_result) do
				local hex, event = r.hex, r.event
				local id = hex.id
				hex.on_event(event, next_step_event)
				if id ~= hex.id then
					depth_result[hex] = id
				end
			end

			depth = depth + 1
			local row = rows[depth]
			if row then
				for _, h in ipairs(row) do
					local hex = self._hexagons[h.rx][h.ry]				
					local id = hex.id
					hex.on_event('lineup', next_step_event)
					if id ~= hex.id then
						depth_result[hex] = id
					end
				end
			end

			result[depth] = depth_result
			event_result = next_step_event

			if #next_step_event <= 0 and depth >= #rows then
				break
			end
		end
		
		return result
	end

	function self.undo_lineup(result)		
		for depth = #result, 1, -1 do
			local depth_result = result[depth]
			for hex, id in pairs(depth_result) do
				hex.id = id				
			end
		end		
	end

	function self._resort_lineup_result(result)
		local record = {}
		local remove = {}
		for _, ent in ipairs(result) do
			local hex, id, depth = ent[1], ent[2], ent[3]
			if not record[hex.rx] then record[hex.rx] = {} end

			local ent0 = record[hex.rx][hex.ry]
			if not ent0 then
			 	record[hex.rx][hex.ry] = ent
			else
				local hex0, id0, depth0 = ent0[1], ent0[2], ent0[3]
				if depth < depth0 then
					record[hex.rx][hex.ry] = ent
					if id == hexagon.HEX_SLOT then
						ent[3] = id0
					end
					table.insert(remove, ent0)
				else
					table.insert(remove, ent)
				end
			end
		end

		for _, ent1 in ipairs(remove) do
			for i, ent2 in ipairs(result) do
				if ent1 == ent2 then
					table.remove(result, i)
					local h, id, depth = ent1[1], ent1[2], ent1[3]
					printf('remove type=%d pos=(%d,%d) depth=%d', id, h.rx, h.ry, depth)
					break
				end
			end
		end

		return result
	end

	function self._get_lineup_max_depth(result)
		local max_depth = 0
		for _, ent in ipairs(result) do
			local depth = ent[3]
			if depth > max_depth then
				max_depth = depth
			end
		end
		return max_depth
	end

	function self.start_lineup_ani1(end_cb)
		local rows = self.get_lineup_rows()
		local result = self.lineup()
		for _, r in ipairs(result) do
			local h, id, depth = r[1], r[2], r[3]
			printf('type=%d pos=(%d,%d) depth=%d', id, h.rx, h.ry, depth)
		end
		self.undo_lineup(result)

		self._lineup_max_depth = self._get_lineup_max_depth(result)
		self._lineup_result = result
		self._lineup_rows = rows
		self._lineup_ani_depth = 0
		self._is_lineup_ani_end = false
		self._start_next_lineup_ani()
		self._lineup_ani_end_cb = end_cb
	end

	function self.start_lineup_ani(end_cb)
		local rows = self.get_lineup_rows()
		local result = self.lineup()
		for depth, r in ipairs(result) do
			for h, id in pairs(r) do				
				printf('type=%d pos=(%d,%d) depth=%d', id, h.rx, h.ry, depth)
			end			
		end
		self.undo_lineup(result)

		self._lineup_max_depth = #result
		self._lineup_result = result
		self._lineup_rows = rows
		self._lineup_ani_depth = 0
		self._is_lineup_ani_end = false
		self._lineup_ani_end_cb = end_cb
		self._start_next_lineup_ani()
	end

	function self._start_next_lineup_ani()
		local depth = self._lineup_ani_depth + 1		
		if depth > self._lineup_max_depth then
			self._is_lineup_ani_end = true
			if self._lineup_ani_end_cb then
				self._lineup_ani_end_cb()
			end
			return
		end

		-- add row lineup ani
		local row = self._lineup_rows[depth]
		if row then
			local ani = row_ani.create(row)			
			table.insert(self._lineup_ani_objs, ani)			
		end

		-- add other hex explotion ani
		for hex, id in pairs(self._lineup_result[depth]) do
			if id == hexagon.HEX_ICING then
				table.insert(self._lineup_ani_objs, icing_ani.create(hex))					
				hex.id = hexagon.HEX_SLOT				
			elseif id == hexagon.HEX_BOMB then
				local ani = bomb_ani.create(hex)
				ani.on_bomb(function ()
					hex.id = hexagon.HEX_SLOT					
				end)
				table.insert(self._lineup_ani_objs, ani)			
			else
				hex.id = hexagon.HEX_SLOT
			end			
		end

		self._lineup_ani_depth = depth		
	end	

	function self.is_lineup_ani_end()
		return self._is_lineup_ani_end
	end

	-- return
	-- rows = {hex_list1, hex_list2, ..}	
	function self.get_lineup_rows()
		local rows = {}
		for k, r in pairs(self._line_up) do
			for b, v in pairs(r) do
				if v then
					table.insert(rows, self._kb_hex[k][b])
				end
			end
		end
				
		return rows
	end

	function self.clear_all()
		self.foreach_hex(function (h)
			h.id = 0
		end)
	end	

	function self.hex_count()
		return self._hex_count
	end

	function self.empty_hex_count()
		self._update_empty_hex_count()
		return self._empty_hex_count
	end

	function self.is_all_clear()
		return self.empty_hex_count() == self._hex_count
	end

	function self._random_hex(type)
		local empty_hexs = {}
		self.foreach_hex(function (h)
			if h.is_empty() then
				table.insert(empty_hexs, h)
			end
		end)
		if #empty_hexs > 0 then
			local h = empty_hexs[math.random(1, #empty_hexs)]
			h.id = type	
		end
	end

	function self.random_icing()
		self._random_hex(hexagon.HEX_ICING)
	end

	function self.random_bomb()
		self._random_hex(hexagon.HEX_BOMB)
	end	

	self.init(s, x, y)
	return self
end
