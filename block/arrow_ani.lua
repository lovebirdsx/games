require('ani')
require('sound')
require('render')
require('hexagon')

arrow_ani = {}

local ARROW_ROTATO = {
	[hexagon.HEX_2ARROW1] = 0,
	[hexagon.HEX_2ARROW2] = math.rad(240),
	[hexagon.HEX_2ARROW3] = math.rad(120)
}

function arrow_ani.create(hex, max_line_count)
	local ani = ani.create(render.get_img('lightning'), 1, 8, 10)	
	ani.set_pos(hex.get_kb_center())
	ani.set_rotato(ARROW_ROTATO[hex.id])
	local kb_line_count = hex.get_kb_count()
	local scale = kb_line_count / max_line_count * 0.8
	ani.set_scale(scale, 1)
	return ani
end
