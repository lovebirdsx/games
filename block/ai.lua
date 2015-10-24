require('board')

ai = {}

local CFG = {
	[1] = 0.9,
	[2] = 0.8,
	[3] = 0,
}

local _max_socre = nil

function ai.get_max_score()
	if not _max_socre then
		local b = board.create()
		_max_socre = ai.evaluate(b)
	end

	return _max_socre
end

function ai.get_depth(board, blocks)	 
	return #blocks
	-- if #blocks ~= #CFG then
	-- 	return #blocks
	-- end

	-- local total = board.hex_count()
	-- local empty = board.empty_hex_count()
	-- local rate = empty / total

	-- for i, r in ipairs(CFG) do
	-- 	if rate >= r then
	-- 		return i
	-- 	end
	-- end
end

-- return best_move, socre
-- best_move = {block, block_pos, rx, ry, can_line_up, next_best_move}
function ai.get_best_move(board, blocks)
	local depth = ai.get_depth(board, blocks)
	return ai.get_best_move_depth(board, blocks, depth)
end

function ai.get_best_move_depth(board, blocks, depth)
	local moves = ai.get_all_moves(board, blocks)	
	if #moves == 0 or depth == 0 then
		return nil, ai.evaluate(board)
	end
		
	local best_move = nil
	local best_next_move = nil
	local best_can_line_up = false
	local score = 0
	local pass_no_line_up_block = false	
	for _, m in ipairs(moves) do
		board.locate_by_rx_ry(m.block, m.rx, m.ry)
		local score0 = 0
		local next_move = nil
		local can_line_up = false
		if board.can_line_up() then
			local result = board.get_line_up_result()			
			for _, hex_list in ipairs(result) do
				board.clear(hex_list)
			end

			table.remove(blocks, m.block_pos)			
			next_move, score0 = ai.get_best_move_depth(board, blocks, depth - 1)
			table.insert(blocks, m.block_pos, m.block)

			for _, hex_list in ipairs(result) do
				board.update(hex_list)
			end

			if depth == 1 then
				pass_no_line_up_block = true
			end
			can_line_up = true
		else
			if not pass_no_line_up_block then
				table.remove(blocks, m.block_pos)
				next_move, score0 = ai.get_best_move_depth(board, blocks, depth - 1)			
				table.insert(blocks, m.block_pos, m.block)
			end
		end

		board.unlocate(m.block, m.rx, m.ry)

		if score0 > score then
			score = score0
			best_move = m
			best_next_move = next_move
			best_can_line_up = can_line_up
		end
	end

	best_move.next_move = best_next_move
	best_move.can_line_up = best_can_line_up
	return best_move, score
end

function ai.get_all_moves(board, blocks)
	local moves = {}
	local move_record = {}
	for i, b in ipairs(blocks) do
		if not move_record[b.type] then
			move_record[b.type] = true
			board.foreach_hex(function (h)
				if board.can_locate_by_rx_ry(b, h.rx, h.ry) then
					table.insert(moves, {block=b, block_pos=i, rx=h.rx, ry=h.ry})
				end
			end)
		else
			-- print('ignore repeat move block ' .. b.type)
		end
	end
	return moves
end

local IDS = {{-1,2},{1,2},{-2,0},{2,0},{-1,-2},{1,-2}}
function ai.evaluate(board)
	local score = 0
	board.foreach_hex(function (h)
		if h.can_locate() then
			for _, id in ipairs(IDS) do
				local r, c = h.rx + id[1], h.ry + id[2]
				local h1 = board.get_hex(r, c)
				if h1 and h1.can_locate() then
					score = score + 1
				end
			end
		end
	end)
	return score
end
