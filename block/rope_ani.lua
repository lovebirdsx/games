require('ani')
require('sound')
require('render')
require('hexagon')

rope_ani = {}

function rope_ani.create(hex)
	local ani = ani.create(render.get_img('rope_ani'), 8, 6, 80)	
	ani.set_pos(hex.x, hex.y)	
	ani.set_scale(scale, 1)
	return ani
end
