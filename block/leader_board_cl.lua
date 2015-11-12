require('class')
require('socket')
require('misc')

LeaderBoardClient = class(function (self, addr, port)
	self.addr = addr
	self.port = port
end)

function LeaderBoardClient:do_req(req)
	local req_s = serialize(req)
	local cl = socket.tcp()
	cl:connect(self.addr, self.port)
	cl:send(req_s:gsub('\n', '') .. '\n')
	local resp_s = cl:receive('*a')
	return unserialize(resp_s)
end

function LeaderBoardClient:get_all()
	return self:do_req({cmd = 'get_all'})
end

function LeaderBoardClient:add(player, score)
	return self:do_req({cmd = 'add', player = player, score = score})
end
