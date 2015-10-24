font = {}

local _font_map = {}

function font.init()
	local font_cfg = {
		{type = 'normal', file = 'fonts/comic.ttf', size = 12},
		{type = 'big', file = 'fonts/comic.ttf', size = 20},
		{type = 'hurge', file = 'fonts/comic.ttf', size = 40}
	}

	for _, cfg in ipairs(font_cfg) do
		local f = love.graphics.newFont(cfg.file, cfg.size)
		_font_map[cfg.type] = f
	end
end

function font.print(type, text, x, y)
	love.graphics.setFont(_font_map[type])
	love.graphics.print(text, x, y)
end
