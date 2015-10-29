require('sound')
require('render')

icing_ani = {}

local INTERVAL = 1 / 80
local COUNT = 6 * 8

function icing_ani.create(hex)
	local self = {}	
	local is_end = false
	local on_bomb_cb
	local on_bomb_cb_called = false
	local t = 0
	local cell_id = 1

	function self.on_bomb(cb)
		on_bomb_cb = cb
	end

	function self.update(dt)
		t = t + dt
		cell_id = math.ceil(t / INTERVAL) + 1
		if cell_id > 10 and not on_bomb_cb_called then
			if on_bomb_cb then
				on_bomb_cb()
			end
			on_bomb_cb_called = true
		end

		if cell_id > COUNT then
			cell_id = COUNT			
			is_end = true
		end
	end

	function self.draw()
		love.graphics.setColor(255, 255, 255, 255)
		render.draw_icing_ani(cell_id, hex.x, hex.y, 1)
	end

	function self.is_end()
		return is_end
	end

	return self
end
