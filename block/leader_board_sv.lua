require('misc')
require('server')
require('config')
require('leader_board')

local lb

function on_add(req)
	lb:add(req.player, req.score)
	lb:save()
	return true
end

function on_get_all(req)
	return lb:get_all()
end

local REQ_FUN = {
	['add'] = on_add,
	['get_all'] = on_get_all,
}

function do_req(req_s)	
	local req = unserialize(req_s)
	if req then
		local fun = REQ_FUN[req.cmd]
		if fun then
			local resp = fun(req)
			local resp_s = serialize(resp)
			return resp_s:gsub('\n', '')
		end
	end
end

function main()
	lb = LeaderBoard(config.leader_board_save)
	start_server(config.port, do_req)
end

main()
