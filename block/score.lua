score = {}

function score.block_score(b)
	return b.hex_count() * 10
end

function score.lineup_score(line_up_result)
	local line_up_times = #line_up_result
	local line_up_hex_count = 0
	for _, hex_list in ipairs(line_up_result) do
		line_up_hex_count = line_up_hex_count + #hex_list
	end
	return line_up_hex_count * (line_up_times + 1) * 10
end

function score.get_score(b, line_up_result)
	if not line_up_result then
		return score.block_score(b)
	else
	    return score.block_score(b) + score.lineup_score(line_up_result)
	end
end
