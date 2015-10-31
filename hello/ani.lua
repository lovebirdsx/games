ani = {}

local function create_quads(img, cell_x, cell_y)
	local iw, ih = img:getDimensions()
	local w, h = iw / cell_x, ih / cell_y
	local quads = {}
	for r = 1, cell_y do
		for c = 1, cell_x do
			local q = love.graphics.newQuad((c-1)*w, (r-1)*h, w, h, iw, ih)
			quads[(r - 1) * 8 + c] = q			
		end
	end
	return quads
end 

function ani.create(img_or_file, cell_x, cell_y, frame_rate)
	local self = {}
	local _is_end = false
	local _on_end_cb
	local _on_end_cb_called = false
	local _t = 0
	local _cell_id = 1
	local _img = type(img_or_file) == 'string' 
		and love.graphics.newImage(img_or_file) or img_or_file
	local _quads = create_quads(_img, cell_x, cell_y)
	local _ox = _img:getWidth() / cell_x / 2
	local _oy = _img:getHeight() / cell_y / 2
	local _interval = 1 / frame_rate
	local _scale = 1
	local _x, _y = 0, 0

	function self.start()
		_is_end = false
		_cell_id = 1
		_t = 0
	end

	function self.on_end(cb)
		_on_end_cb = cb
	end

	function self.set_pos(x, y)
		_x, _y = x, y
	end

	function self.set_scale(scale)
		_scale = scale
	end

	function self.update(dt)
		if _is_end then return end

		_t = _t + dt
		_cell_id = math.ceil(_t / _interval) + 1

		if _cell_id > cell_x * cell_y then
			_cell_id = cell_x * cell_y
			_is_end = true
			if _on_end_cb then
				_on_end_cb()
			end
		end
	end

	function self.draw()
		if _is_end then return end
		
		love.graphics.draw(_img, _quads[_cell_id], _x, _y, 0, _scale, _scale, _ox, _oy)
	end

	function self.is_end()
		return _is_end
	end

	return self
end
