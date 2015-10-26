local BG_COLOR = {32, 32, 30}

local _img_hex
local _img_shadow
local _img_icing
local _quad_hex_left
local _quad_hex_right
local _quad_shadow
local _quad_icing

render = {}

function render.init()
	_img_hex = love.graphics.newImage('image/hex.png')
	_img_shadow = love.graphics.newImage('image/shadow.png')
	_img_icing = love.graphics.newImage('image/icing.png')
	local sw, sh = _img_hex:getDimensions()
	_quad_hex_left = love.graphics.newQuad(0, 0, sw / 2, sh, sw, sh)
	_quad_hex_right = love.graphics.newQuad(sw / 2, 0, sw / 2, sh, sw, sh)
	_quad_icing = love.graphics.newQuad(0, 0, sw / 2, sh, _img_icing:getDimensions())
	sw, sh = _img_shadow:getDimensions()
	_quad_shadow = love.graphics.newQuad(0, 0, sw, sh, sw, sh)
end

function render._draw_hex(img, quad, x, y, scale)
	scale = (scale or 1) * 0.4
	local qx, qy, qw, qh = quad:getViewport()
	local offset_x = qw * scale / 2
	local offset_y = qh * scale / 2
	love.graphics.draw(img, quad, x - offset_x, y - offset_y, 0, scale, scale)
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

function render.draw_hex_shadow(x, y, scale)
	render._draw_hex(_img_shadow, _quad_shadow, x, y, scale)
end

function render.draw_bg()
	love.graphics.setColor(BG_COLOR[1], BG_COLOR[2], BG_COLOR[3])
	love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end
