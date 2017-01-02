require('class')
require('block')

local BLOCK_CFG = {
	{type=1, id=6, class=1, pos_list={{0, 0},}},
	{type=2, id=1, class=1, pos_list={{-2, 0},{0, 0},{2, 0},{4, 0},}},
	{type=3, id=1, class=1, pos_list={{2, -4},{1, -2},{0, 0},{-1, 2},}},
	{type=4, id=1, class=1, pos_list={{-1, -2},{0, 0},{1, 2},{2, 4},}},
	{type=37, id=5, class=1, pos_list={{0, 0},{2, 0},}},
	{type=38, id=5, class=1, pos_list={{1, -2},{0, 0},}},
	{type=39, id=5, class=1, pos_list={{-1, -2},{0, 0},}},
	{type=40, id=2, class=1, pos_list={{-2, 0},{0, 0},{2, 0},}},
	{type=41, id=5, class=1, pos_list={{1, -2},{0, 0},{-1, 2},}},
	{type=42, id=5, class=1, pos_list={{-1, -2},{0, 0},{1, 2},}},
	{type=43, id=2, class=1, pos_list={{-1, -2},{-2, 0},{0, 0},}},
	{type=44, id=2, class=1, pos_list={{-1, -2},{1, -2},{-2, 0},}},
	{type=45, id=2, class=1, pos_list={{-1, -2},{1, -2},{2, 0},}},
	{type=46, id=2, class=1, pos_list={{1, -2},{2, 0},{1, 2},}},
	{type=47, id=2, class=1, pos_list={{2, 0},{-1, 2},{1, 2},}},
	{type=48, id=2, class=1, pos_list={{-2, 0},{-1, 2},{1, 2},}},
	{type=49, id=2, class=1, pos_list={{-1, -2},{-2, 0},{-1, 2},}},
	{type=5, id=5, class=2, pos_list={{1, -2},{-2, 0},{0, 0},{2, 0},}},
	{type=6, id=5, class=2, pos_list={{-1, -2},{-2, 0},{0, 0},{2, 0},}},
	{type=7, id=5, class=2, pos_list={{-2, 0},{0, 0},{2, 0},{-1, 2},}},
	{type=8, id=5, class=2, pos_list={{-2, 0},{0, 0},{2, 0},{1, 2},}},
	{type=9, id=2, class=2, pos_list={{-1, -2},{1, -2},{-2, 0},{0, 0},}},
	{type=10, id=2, class=2, pos_list={{-1, -2},{1, -2},{0, 0},{2, 0},}},
	{type=11, id=2, class=2, pos_list={{-1, -2},{-2, 0},{0, 0},{-1, 2},}},
	{type=12, id=4, class=2, pos_list={{1, -2},{-2, 0},{0, 0},{-1, 2},}},
	{type=13, id=4, class=2, pos_list={{1, -2},{0, 0},{-1, 2},{1, 2},}},
	{type=14, id=4, class=2, pos_list={{1, -2},{0, 0},{2, 0},{-1, 2},}},
	{type=15, id=4, class=2, pos_list={{-1, -2},{1, -2},{0, 0},{-1, 2},}},
	{type=16, id=4, class=2, pos_list={{-1, -2},{0, 0},{-1, 2},{1, 2},}},
	{type=17, id=4, class=2, pos_list={{-1, -2},{0, 0},{2, 0},{1, 2},}},
	{type=18, id=4, class=2, pos_list={{-1, -2},{-2, 0},{0, 0},{1, 2},}},
	{type=19, id=4, class=2, pos_list={{-1, -2},{1, -2},{0, 0},{1, 2},}},
	{type=20, id=3, class=3, pos_list={{-1, -2},{-2, 0},{-1, 2},{1, 2},}},
	{type=21, id=3, class=3, pos_list={{1, -2},{2, 0},{-1, 2},{1, 2},}},
	{type=22, id=3, class=3, pos_list={{-1, -2},{1, -2},{-2, 0},{-1, 2},}},
	{type=23, id=3, class=3, pos_list={{-1, -2},{1, -2},{2, 0},{1, 2},}},
	{type=24, id=3, class=3, pos_list={{-2, 0},{2, 0},{-1, 2},{1, 2},}},
	{type=25, id=3, class=3, pos_list={{-1, -2},{1, -2},{-2, 0},{2, 0},}},
	{type=26, id=2, class=3, pos_list={{-1, -2},{1, -2},{0, 0},{-1, 2},{1, 2},}},
	{type=27, id=6, class=4, pos_list={{1, -2},{-2, 0},{0, 0},{2, 0},{1, 2},}},
	{type=28, id=6, class=4, pos_list={{-1, -2},{-2, 0},{0, 0},{2, 0},{-1, 2},}},
	{type=29, id=6, class=4, pos_list={{-1, -2},{-2, 0},{0, 0},{2, 0},{1, 2},}},
	{type=30, id=6, class=4, pos_list={{1, -2},{-2, 0},{0, 0},{2, 0},{-1, 2},}},
	{type=31, id=3, class=4, pos_list={{1, -2},{0, 0},{2, 0},{-1, 2},{1, 2},}},
	{type=32, id=3, class=4, pos_list={{-2, 0},{0, 0},{2, 0},{-1, 2},{1, 2},}},
	{type=33, id=3, class=4, pos_list={{-1, -2},{-2, 0},{0, 0},{-1, 2},{1, 2},}},
	{type=34, id=3, class=4, pos_list={{-1, -2},{1, -2},{-2, 0},{0, 0},{-1, 2},}},
	{type=35, id=3, class=4, pos_list={{-1, -2},{1, -2},{-2, 0},{0, 0},{2, 0},}},
	{type=36, id=3, class=4, pos_list={{-1, -2},{1, -2},{0, 0},{2, 0},{1, 2},}},
}

local BLOCK_POS_MAP = {
	[1] = {{0, 200},},
	[2] = {{0, 80}, {0, 220}, },
	[3] = {{0, 0},  {0, 150}, {0, 300},	},
	[4] = {{0, 0},  {0, 120}, {0, 240}, {0, 360}, }
}

local SCALE = 0.6
local NORMAL_SCALE = 1

function gen_class_offset()
	local r = {}
	for i, cfg in ipairs(BLOCK_CFG) do
		r[cfg.class] = i
	end
	return r
end

function get_block_cfg_by_types()
	local r = {}
	for i, cfg in ipairs(BLOCK_CFG) do
		r[cfg.type] = cfg
	end
	return r
end

BlockGenerator = class(function (self)
	self.max_block_count = 3
	self.x, self.y = 0, 0
	self.blocks = {}
	self.can_refill = true
	self.scale = 1
	self.class_offset = gen_class_offset()
	self.block_cfg_by_types = get_block_cfg_by_types()
	self.block_cfg = BLOCK_CFG
	self.gen_end_id = self.class_offset[1]
end)

function BlockGenerator:set_max_block_count(count)
	self.max_block_count = count
end

function BlockGenerator:set_class(class)	
	self.gen_end_id = self.class_offset[class]	
end

function BlockGenerator:fill_all()
	for i = 1, self.max_block_count do
		local b = self:gen()
		b.id = i
		b.set_pos(self:get_block_pos(i))
		b.set_scale(self.scale * SCALE)
		self.blocks[i] = b
	end
end

function BlockGenerator:get_block_pos(id)
	local pos = BLOCK_POS_MAP[self.max_block_count][id]	
	return self.x + pos[1], self.y + pos[2]
end

function BlockGenerator:set_pos(x, y)
	self.x, self.y = x, y
	for i, b in ipairs(self.blocks) do
		b.set_pos(self:get_block_pos(i))
	end
end

function BlockGenerator:gen_snapshot()
	local snapshot = {}
	local types = {}
	for i = 1, #self.blocks do
		types[i] = self.blocks[i].type
	end	
	snapshot.types = types
	snapshot.max_block_count = self.max_block_count
	return snapshot
end

function BlockGenerator:apply_snapshot(s)
	self.max_block_count = s.max_block_count
	for i=1,self.max_block_count do		
		local b = self:gen(s.types[i])
		b.id = i
		b.set_pos(self:get_block_pos(i))
		b.set_scale(self.scale * SCALE)
		self.blocks[i] = b
	end
end

function BlockGenerator:random_type()
	if math.random() < 0.125 then
		return 1
	else
	    return math.random(2, self.gen_end_id)
	end
end

function BlockGenerator:gen(block_type)
	local cfg
	if block_type then
		cfg = self.block_cfg_by_types[block_type]
	else
		cfg = self.block_cfg[self:random_type()]
	end

	local b = block.create(cfg.pos_list, cfg.id)
	b.type = cfg.type

	return b
end

function BlockGenerator:update(dt)
	
end

function BlockGenerator:draw()
	for _, b in ipairs(self.blocks) do
		if b ~= self.selected_block then
			b.draw()
		end
	end

	if self.selected_block then
		self.selected_block.draw()
	end
end

function BlockGenerator:get_block_by_pos(x, y)
	for _, b in ipairs(self.blocks) do
		if b.test_point(x, y, 1.2) then
			return b
		end
	end
	return nil
end

function BlockGenerator:select_block(b)
	b.set_scale(self.scale * NORMAL_SCALE)
	b.set_draw_scale(self.scale * NORMAL_SCALE * 0.9)
	self.selected_block = b
end

function BlockGenerator:reset_block(b)
	b.set_pos(self:get_block_pos(b.id))
	b.set_scale(self.scale * SCALE)
	b.set_draw_scale(1)
end

function BlockGenerator:reset()
	for i = self.max_block_count + 1, #self.blocks do
		self.blocks[i] = nil
	end

	for i = 1, self.max_block_count do
		local b = self.blocks[i]
		if not b then
			b = self:gen()
			self.blocks[i] = b
			b.id = i
		end

		self:reset_block(b)
	end
end

function BlockGenerator:unselect()
	if self.selected_block then
		self:reset_block(self.selected_block)
		self.selected_block = nil
	end
end

function BlockGenerator:remove_select()
	for i, b in ipairs(self.blocks) do
		if b == self.selected_block then
			table.remove(self.blocks, i)
		end
	end
	
	self.selected_block = nil
end

function BlockGenerator:set_can_refill(bool)
	self.can_refill = bool
end

function BlockGenerator:refill()
	if not self.can_refill then return end

	for i = 1, #self.blocks do
		self.blocks[i].id = i
		self:reset_block(self.blocks[i])
	end

	local b = self:gen()
	b.id = self.max_block_count
	self:reset_block(b)
	self.blocks[#self.blocks + 1] = b
end

function BlockGenerator:get_blocks()
	return self.blocks
end

function BlockGenerator:is_clear()
	return #self.blocks == 0
end

function BlockGenerator:update_blocks(blocks)
	for i, b in ipairs(blocks) do
		local b0 = self:gen(b.type)
		b0.id = i
		b0.set_pos(self:get_block_pos(i))
		b0.set_scale(self.scale * SCALE)
		self.blocks[i] = b0
	end
end

function BlockGenerator:set_scale(scale)
	self.scale = scale

	for i = 1, self.max_block_count do		
		b = self.blocks[i]		
		b.set_scale(self.scale * SCALE)		
	end
end
