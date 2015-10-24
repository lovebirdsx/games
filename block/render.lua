local BG_COLOR = {32, 32, 30}

local _img_hex = nil
local _img_shadow = nil
local _hex_left = nil
local _hex_right = nil

render = {}

function render.init()
	_img_hex = love.graphics.newImage("image/hex.png")
	_img_shadow = love.graphics.newImage("image/shadow.png")
	local sw, sh = _img_hex:getDimensions()
	_hex_left = love.graphics.newQuad(0, 0, sw / 2, sh, sw, sh)
	_hex_right = love.graphics.newQuad(sw / 2, 0, sw / 2, sh, sw, sh)
end

function render._draw_hex(quad, x, y, scale)
	scale = (scale or 1) * 0.4
	local w = _img_hex:getWidth() / 2
	local h = _img_hex:getHeight()
	local offset_x = w * scale / 2
	local offset_y = h * scale / 2
	love.graphics.draw(_img_hex, quad, x - offset_x, y - offset_y, 0, scale, scale)
end

function render.draw_hex(c, x, y, scale, alpha)
	love.graphics.setColor(c[1], c[2], c[3], alpha)
	if id == 0 then
		render._draw_hex(_hex_right, x, y, scale)
	else		
		render._draw_hex(_hex_left, x, y, scale)
	end
end

function render.draw_hex_shadow(x, y, scale)
	love.graphics.setColor(255, 255, 255, 255)
	scale = (scale or 1) * 0.5
	local w = _img_shadow:getWidth()
	local h = _img_shadow:getHeight()
	local offset_x = w * scale / 2
	local offset_y = h * scale / 2
	love.graphics.draw(_img_shadow, x - offset_x, y - offset_y, 0, scale, scale)
end

function render.draw_bg()
	love.graphics.setColor(BG_COLOR[1], BG_COLOR[2], BG_COLOR[3])
end
