require('board')
require('block_mgr')
require('ai')
require('stage')

local function gen_different_block(block_count)
	local blocks = {}
	local record = {}
	local max_block_type = block_mgr.max_block_type()
	for j = 1, block_count do
		local btype = math.random(2, max_block_type)
		while record[btype] do
			btype = math.random(2, max_block_type)
		end
		record[btype] = true
		local b = block_mgr.gen(btype)
		b.id = j
		table.insert(blocks, b)
	end
	return blocks
end

local BLOCK_GEN_FUNS = {
	[1] = gen_different_block,
}

local function gen_board_ex(board, hex_total, ...)
	local hexs = {}
	board.foreach_hex(function (h)
		h.id = 0
		table.insert(hexs, h)
	end)

	-- remove empty hex
	local cut_off = board.hex_count() - hex_total
	local i = 0
	while i < cut_off do
		local c = math.random(3, 5)
		i = i + c
		if i > cut_off then
			c = c - (i - cut_off)
			i = cut_off
		end
		local start = math.random(1, #hexs - c)
		for j = 1, c do
			table.remove(hexs, start)
		end
	end

	-- set no color hex types
	local cfg_list = {...}
	for i = 1, #cfg_list / 2 do
		local type = cfg_list[i * 2 - 1]
		local count = cfg_list[i * 2]
		for j = 1, count do
			local id = math.random(1, #hexs)
			hexs[id].id = type
			table.remove(hexs, id)
		end
	end

	-- set for color hex types
	for _, h in ipairs(hexs) do
		h.id = math.random(1, hexagon.max_color)
	end
end

local function gen_board_color(board, hex_count)
	gen_board_ex(board, hex_count)
end

local function gen_board_icing(board, hex_count)
	gen_board_ex(board, hex_count, 
		hexagon.HEX_ICING, 	math.ceil(hex_count / 4))
end

local function gen_board_bomb(board, hex_count)
	gen_board_ex(board, hex_count, 
		hexagon.HEX_BOMB, 	math.ceil(hex_count / 4))
end

local function gen_board_icing_and_bomb(board, hex_count)
	gen_board_ex(board, hex_count, 
		hexagon.HEX_ICING, 	math.ceil(hex_count / 8),
		hexagon.HEX_BOMB, 	math.ceil(hex_count / 8))
end

local BOARD_GEN_FUNS = {
	[1]	= gen_board_color,
	[2] = gen_board_icing,
	[3] = gen_board_bomb,
	[4] = gen_board_icing_and_bomb,
}

stage_gen = {}

local _debug = false
local _block_gen_fun = BLOCK_GEN_FUNS[1]
local _board_gen_fun = BOARD_GEN_FUNS[1]

function stage_gen.debug(bool)
	_debug = bool
end

local function printf(fmt, ...)
	if _debug then
		print(string.format(fmt, ...))
	end
end

local function is_last_move_line_up(best_move, depth)
	if not best_move then return false end

	local m = best_move
	for d = 2, depth do
		m = m.next_move
		if not m then return false end
	end

	return m.can_line_up
end

function stage_gen.set_gen_block_fun(id)
	_block_gen_fun = BLOCK_GEN_FUNS[id]
end

function stage_gen.set_gen_board_fun(id)
	_board_gen_fun = BOARD_GEN_FUNS[id]
end


-- return ok, blocks, best_move
function stage_gen.gen(board, seed, hex_count, block_count)	
	math.randomseed(seed)
	_board_gen_fun(board, hex_count)
	local blocks = _block_gen_fun(block_count)
	local best_move, score = ai.get_best_move(board, blocks)
	if is_last_move_line_up(best_move, block_count) then
		if stage_gen.remove_left_hex_depth(board, best_move, block_count) then
			if stage_gen.stage_ok(board, best_move) then
				return board, blocks, best_move
			end
		end
	end
	return false
end

function stage_gen.stage_ok(board, m)
	local snapshot = board.gen_snapshot()
	while m do
		board.locate_by_rx_ry(m.block, m.rx, m.ry)
		if board.can_line_up() then
			board.lineup()
		end
		m = m.next_move
	end

	local ok = board.is_all_clear()
	if ok then
		board.apply_snapshot(snapshot)
	end
	return ok
end

function stage_gen.remove_left_hex_depth(board, m, depth)
	local r = false
	if not m then
		if depth == 0 then
			board.clear_all()			
			r = true
		end			
	else
		board.locate_by_rx_ry(m.block, m.rx, m.ry)		
		if board.can_line_up() then
			local lineup_result = board.lineup()
			r = stage_gen.remove_left_hex_depth(board, m.next_move, depth - 1)
			board.undo_lineup(lineup_result)
		else
			r = stage_gen.remove_left_hex_depth(board, m.next_move, depth - 1)
		end

		board.undo_locate(m.block, m.rx, m.ry)
	end

	return r
end

require('lfs')
function main()
	local RAND_MAX = 32767
	local board = board.create()
	local hex_count = 30
	local block_count = 3
	local gen_block_fun_id = 1
	local gen_board_fun_id = 4

	stage_gen.set_gen_board_fun(gen_board_fun_id)
	stage_gen.set_gen_block_fun(gen_block_fun_id)
	stage_gen.debug(true)
	for seed = 1, RAND_MAX do
		local board, blocks, best_move = stage_gen.gen(board, seed, hex_count, block_count)
		io.write(string.format('block = %d, hex = %d, block_fun = %d, board_fun = %d, seed = %d\r', 
			block_count, hex_count, gen_block_fun_id, gen_board_fun_id, seed))
		if board then
			local filepath = string.format('stages/[%d-%d][%d-%d][%d]',
				gen_board_fun_id, gen_block_fun_id, hex_count, block_count, seed)
			stage.save(board, blocks, best_move, filepath)
			printf('save %s\t\t\t\t\t', filepath)
		end
	end
end

main()
