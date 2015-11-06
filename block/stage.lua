require('misc')
require('board')
require('block_mgr')
require('log')
stage = {}

function stage.save(board, blocks, best_move, file)
	local save = {}
	local block_types = {}
	local moves = {}
	save.board = board.gen_snapshot()

	for i, b in ipairs(blocks) do
		block_types[i] = b.type
		b.id = i
	end
	save.block_types = block_types

	local m = best_move
	while m do
		moves[#moves + 1] = {
			rx = m.rx, 
			ry = m.ry,
			b_id = m.block.id,
		}
		m = m.next_move
	end
	save.moves = moves
	
	write_file(file, serialize(save))
end

function stage.load_by_str(str)
	local save = unserialize(str)
	if not save then		
		return nil
	end
	local board = board.create()
	board.apply_snapshot(save.board)

	local blocks = {}
	for i, btype in ipairs(save.block_types) do
		blocks[i] = block_mgr.gen(btype)
	end

	local prev_m = nil
	local curr_m = nil
	for i = #save.moves, 1, -1 do
		local m = save.moves[i]
		curr_m = {rx = m.rx, ry = m.ry, block_pos=m.b_id, block=blocks[m.b_id], next_move=prev_m}
		prev_m = curr_m
	end

	return board, blocks, curr_m
end

-- return board, blocks, move
function stage.load(file)
	return stage.load_by_str(read_file(file))
end
