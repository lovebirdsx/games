require('block')

local BLOCK_CFG = {
	{id=6, pos_list={{0, 0},}},
	{id=1, pos_list={{-2, 0},{0, 0},{2, 0},{4, 0},}},
	{id=1, pos_list={{2, -4},{1, -2},{0, 0},{-1, 2},}},
	{id=1, pos_list={{-1, -2},{0, 0},{1, 2},{2, 4},}},
	{id=5, pos_list={{1, -2},{-2, 0},{0, 0},{2, 0},}},
	{id=5, pos_list={{-1, -2},{-2, 0},{0, 0},{2, 0},}},
	{id=5, pos_list={{-2, 0},{0, 0},{2, 0},{-1, 2},}},
	{id=5, pos_list={{-2, 0},{0, 0},{2, 0},{1, 2},}},
	{id=2, pos_list={{-1, -2},{1, -2},{-2, 0},{0, 0},}},
	{id=2, pos_list={{-1, -2},{1, -2},{0, 0},{2, 0},}},
	{id=2, pos_list={{-1, -2},{-2, 0},{0, 0},{-1, 2},}},
	{id=4, pos_list={{1, -2},{-2, 0},{0, 0},{-1, 2},}},
	{id=4, pos_list={{1, -2},{0, 0},{-1, 2},{1, 2},}},
	{id=4, pos_list={{1, -2},{0, 0},{2, 0},{-1, 2},}},
	{id=4, pos_list={{-1, -2},{1, -2},{0, 0},{-1, 2},}},
	{id=4, pos_list={{-1, -2},{0, 0},{-1, 2},{1, 2},}},
	{id=4, pos_list={{-1, -2},{0, 0},{2, 0},{1, 2},}},
	{id=4, pos_list={{-1, -2},{-2, 0},{0, 0},{1, 2},}},
	{id=4, pos_list={{-1, -2},{1, -2},{0, 0},{1, 2},}},
	{id=3, pos_list={{-1, -2},{-2, 0},{-1, 2},{1, 2},}},
	{id=3, pos_list={{1, -2},{2, 0},{-1, 2},{1, 2},}},
	{id=3, pos_list={{-1, -2},{1, -2},{-2, 0},{-1, 2},}},
	{id=3, pos_list={{-1, -2},{1, -2},{2, 0},{1, 2},}},
	{id=3, pos_list={{-2, 0},{2, 0},{-1, 2},{1, 2},}},
	{id=3, pos_list={{-1, -2},{1, -2},{-2, 0},{2, 0},}},
}

local BLOCK_POS_MAP = {
	[3] = {
		{700, 150},
		{700, 300},
		{700, 450},
	},
	[4] = {
		{700, 120},
		{700, 240},
		{700, 360},
		{700, 480},
	}
}

local _block_count = 3

local SCALE = 0.6

block_mgr = {}
local _blocks = {}
local _selected_block = nil

function block_mgr.gen_ids_string()
	local r = ''
	for _, cfg in ipairs(BLOCK_CFG) do
		for _, pos in ipairs(cfg.pos_list) do
			r = r .. string.format('(%d,%d,%d);', pos[1], pos[2], cfg.id)
		end
		r = r .. '\n'
	end

	return r
end

local function get_pos(id)
	local pos_list = BLOCK_POS_MAP[_block_count][id]
	return pos_list[1], pos_list[2]
end

function block_mgr.init()	
	for i=1,_block_count do		
		local b = block_mgr.gen()
		b.id = i
		b.set_pos(get_pos(i))
		b.set_scale(SCALE)
		_blocks[i] = b
	end
end

function block_mgr.update(blocks)
	_blocks = {}
	_block_count = #blocks
	for i, b in ipairs(blocks) do
		local b0 = block_mgr.gen(b.type)
		b0.id = i
		b0.set_pos(get_pos(i))
		b0.set_scale(SCALE)
		_blocks[i] = b0
	end
end

function block_mgr.gen_snapshot()
	local snapshot = {}
	local types = {}
	for i = 1, #_blocks do
		types[i] = _blocks[i].type
	end	
	snapshot.types = types
	snapshot.block_count = _block_count
	return snapshot
end

function block_mgr.apply_snapshot(s)
	_block_count = s.block_count
	for i=1,_block_count do		
		local b = block_mgr.gen(s.types[i])
		b.id = i
		b.set_pos(get_pos(i))
		b.set_scale(SCALE)
		_blocks[i] = b
	end
end

function block_mgr._random_type1()
	if math.random() < 0.125 then
		return 1
	else
	    return math.random(2, #BLOCK_CFG)
	end
end

function block_mgr._random_type2()
	local function has_type(type)
		for _, b in ipairs(_blocks) do
			if b.type == type then
				return true
			end
		end
		return false
	end
	while true do
		local type = block_mgr._random_type1()
		if not has_type(type) then
			return type
		end
	end
end

function block_mgr._random_type3()
	return math.random(2, #BLOCK_CFG)
end


function block_mgr.gen(type)
	local type = type or block_mgr._random_type1()
	local cfg = BLOCK_CFG[type]
	local b = block.create(cfg.pos_list, cfg.id, type)
	b.type = type
	return b
end

function block_mgr.gen_stage_block()	
	return block_mgr.gen(block_mgr._random_type3())
end

function block_mgr.draw()
	for _, b in ipairs(_blocks) do
		if b ~= _selected_block then
			b.draw()
		end
	end

	if _selected_block then
		_selected_block.draw()
	end
end

function block_mgr.get_block_by_pos(x, y)
	for _, b in ipairs(_blocks) do
		if b.test_point(x, y, 1.2) then			
			return b
		end
	end
	return nil
end

function block_mgr.select_block(b)
	b.set_scale(1)
	b.set_draw_scale(0.8)
	_selected_block = b
end

function block_mgr._reset(b)
	b.set_pos(get_pos(b.id))
	b.set_scale(SCALE)
	b.set_draw_scale(1)
end

function block_mgr.unselect()
	if _selected_block then
		block_mgr._reset(_selected_block)
		_selected_block = nil
	end
end

function block_mgr.remove_select()
	for i, b in ipairs(_blocks) do
		if b == _selected_block then
			table.remove(_blocks, i)
		end
	end
	
	_selected_block = nil
end

function block_mgr.refill()	
	for i = 1, #_blocks do
		_blocks[i].id = i
		block_mgr._reset(_blocks[i])
	end

	local b = block_mgr.gen()
	b.id = _block_count
	block_mgr._reset(b)
	_blocks[#_blocks + 1] = b	
end

function block_mgr.blocks()
	return _blocks
end

function block_mgr.is_clear()
	return #_blocks == 0
end

function block_mgr.max_block_type()
	return #BLOCK_CFG
end
