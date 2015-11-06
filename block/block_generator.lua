require('class')
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
		{0, 0},
		{0, 150},
		{0, 300},
	},
	[4] = {
		{0, 0},
		{0, 120},
		{0, 240},
		{0, 360},
	}
}

local SCALE = 0.6

BlockGenerator = class(function (self)
	self.max_block_count = 3
	self.x, self.y = 0, 0
	self.blocks = {}
	self.can_refill = true
end)

function BlockGenerator:set_max_block_count(count)
	self.max_block_count = count
end

function BlockGenerator:fill_all()
	for i = #self.blocks + 1, self.max_block_count do
		local b = self:gen()
		b.id = i
		b.set_pos(self:get_block_pos(i))
		b.set_scale(SCALE)
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
	self.max_block_count = s.block_count
	for i=1,self.max_block_count do		
		local b = self:gen(s.types[i])
		b.id = i
		b.set_pos(get_pos(i))
		b.set_scale(SCALE)
		self.blocks[i] = b
	end
end

function BlockGenerator:_random_type()
	if math.random() < 0.125 then
		return 1
	else
	    return math.random(2, #BLOCK_CFG)
	end
end

function BlockGenerator:gen(type)
	local type = type or self:_random_type()
	local cfg = BLOCK_CFG[type]
	local b = block.create(cfg.pos_list, cfg.id, type)
	b.type = type
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
	b.set_scale(1)
	b.set_draw_scale(0.8)
	self.selected_block = b
end

function BlockGenerator:reset(b)
	b.set_pos(self:get_block_pos(b.id))
	b.set_scale(SCALE)
	b.set_draw_scale(1)
end

function BlockGenerator:unselect()
	if self.selected_block then
		self:reset(self.selected_block)
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
		self:reset(self.blocks[i])
	end

	local b = self:gen()
	b.id = self.max_block_count
	self:reset(b)
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
		b0.set_pos(get_pos(i))
		b0.set_scale(SCALE)
		self.blocks[i] = b0
	end
end
