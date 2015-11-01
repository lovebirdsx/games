local BG_COLOR = {32, 32, 30}

local _img_hex
local _img_shadow
local _img_icing
local _img_bomb
local _img_2arrow
local _img_bomb_ani
local _img_icing_ani
local _img_lightning
local _quad_hex_left
local _quad_hex_right
local _quad_shadow
local _quad_icing
local _quad_bomb
local _quad_2arrow
local _quads_bomb_ani
local _quads_icing_ani

render = {}

function _init_quads_bomb_ani()
	local iw, ih = _img_bomb_ani:getDimensions()
	local w, h = iw / 8, ih / 6
	_quads_bomb_ani = {}
	for r = 1, 6 do
		for c = 1, 8 do
			local q = love.graphics.newQuad((c-1)*w, (r-1)*h, w, h, iw, ih)
			_quads_bomb_ani[(r - 1) * 8 + c] = q			
		end
	end
end

function _init_quads_icing_ani()
	local iw, ih = _img_icing_ani:getDimensions()
	local w, h = iw / 8, ih / 6
	_quads_icing_ani = {}
	for r = 1, 6 do
		for c = 1, 8 do
			local q = love.graphics.newQuad((c-1)*w, (r-1)*h, w, h, iw, ih)
			_quads_icing_ani[(r - 1) * 8 + c] = q			
		end
	end
end

function render.init()
	_img_hex = love.graphics.newImage('image/hex.png')
	_img_shadow = love.graphics.newImage('image/shadow.png')
	_img_icing = love.graphics.newImage('image/icing.png')
	_img_bomb = love.graphics.newImage('image/bomb.png')
	_img_2arrow = love.graphics.newImage('image/arrow2.png')
	_img_bomb_ani = love.graphics.newImage('image/bomb_ani.png')
	_img_icing_ani = love.graphics.newImage('image/icing_ani.png')
	_img_lightning = love.graphics.newImage('image/lightning.png')

	local sw, sh = _img_hex:getDimensions()
	_quad_hex_left = love.graphics.newQuad(0, 0, sw / 2, sh, sw, sh)
	_quad_hex_right = love.graphics.newQuad(sw / 2, 0, sw / 2, sh, sw, sh)
	local w, h = _img_shadow:getDimensions()
	_quad_shadow = love.graphics.newQuad(0, 0, w, h, w, h)
	w, h = _img_icing:getDimensions()
	_quad_icing = love.graphics.newQuad(0, 0, w, h, w, h)
	w, h = _img_bomb:getDimensions()
	_quad_bomb = love.graphics.newQuad(0, 0, w, h, w, h)
	w, h = _img_2arrow:getDimensions()
	_quad_2arrow = love.graphics.newQuad(0, 0, w, h, w, h)

	_init_quads_bomb_ani()
	_init_quads_icing_ani()
end

function render.get_img(name)
	if name == 'lightning' then return _img_lightning end
	assert(false)
end

function render._draw_hex(img, quad, x, y, scale, r)
	scale = (scale or 1) * 0.4
	r = (r or 0)
	local qx, qy, qw, qh = quad:getViewport()
	local ox = qw / 2
	local oy = qh / 2
	-- love.graphics.draw(img, quad, x, y, r, scale, scale, offset_x, offset_y)
	love.graphics.draw(img, quad, x, y, r, scale, scale, ox, oy)
end

function render.draw_hex_slot(x, y, scale)
	render._draw_hex(_img_hex, _quad_hex_right, x, y, scale)
end

function render.draw_hex_color(x, y, scale)
	render._draw_hex(_img_hex, _quad_hex_left, x, y, scale)
end

function render.draw_icing(x, y, scale)	
	render._draw_hex(_img_icing, _quad_icing, x, y, scale)
end

function render.draw_bomb(x, y, scale)
	render._draw_hex(_img_bomb, _quad_bomb, x, y, scale)
end

function render.draw_2arrow(x, y, scale, rotato)
	render._draw_hex(_img_2arrow, _quad_2arrow, x, y, scale, rotato)
end

function render.draw_hex_shadow(x, y, scale)
	render._draw_hex(_img_shadow, _quad_shadow, x, y, scale)
end

function render.draw_bomb_ani(cell_id, x, y, scale)	
	local q = _quads_bomb_ani[cell_id]
	local qx, qy, qw, qh = q:getViewport()
	local offset_x = qw * scale / 2
	local offset_y = qh * scale / 2	
	love.graphics.draw(_img_bomb_ani, q,  x - offset_x, y - offset_y, 0, scale, scale)
end

function render.draw_icing_ani(cell_id, x, y, scale)	
	local q = _quads_icing_ani[cell_id]
	local qx, qy, qw, qh = q:getViewport()
	local offset_x = qw * scale / 2
	local offset_y = qh * scale / 2	
	love.graphics.draw(_img_icing_ani, q,  x - offset_x, y - offset_y, 0, scale, scale)
end

function render.draw_bg()
	love.graphics.setColor(BG_COLOR[1], BG_COLOR[2], BG_COLOR[3])
	love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end
