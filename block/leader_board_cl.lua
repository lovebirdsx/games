require('class')
require('socket')
require('misc')
require('font')
require('config')

LeaderBoardClient = class(function (self, addr, port)
	self.addr = addr
	self.port = port
	self.x, self.y = 20, 50
	self:sync()
end)

local instance

function LeaderBoardClient:instance()
	if not instance then
		instance = LeaderBoardClient(config.sv_addr, config.port)
	end
	return instance
end

function LeaderBoardClient:do_req(req)
	local req_s = serialize(req)
	local cl = socket.tcp()
	cl:settimeout(config.timeout)
	cl:connect(self.addr, self.port)
	cl:send(req_s:gsub('\n', '') .. '\n')
	local resp_s = cl:receive()
	cl:close()
	return unserialize(resp_s)
end

function LeaderBoardClient:get_all()
	return self:do_req({cmd = 'get_all'})
end

function LeaderBoardClient:add(player, score)
	return self:do_req({cmd = 'add', player = player, score = score})
end

function LeaderBoardClient:sync()
	self.records = self:get_all()
	self.last_sync_time = love.timer.getTime()
end

local COLOR_BY_RANK = {
	{254, 215, 0},
	{212, 212, 212},
	{184, 115, 51},
	{255, 255, 255},
}

function get_draw_color_by_rank(rank)
	if rank <= #COLOR_BY_RANK then
		return unpack(COLOR_BY_RANK[rank])
	else
		return unpack(COLOR_BY_RANK[#COLOR_BY_RANK])
	end
end

function LeaderBoardClient:draw()
	love.graphics.setColor(255, 255, 255, 255)
	font.print('hurge', 'Leader Board', self.x + 20, self.y)
	love.graphics.rectangle('line', self.x, self.y, 300, 500)
	if self.records then
		for rank, r in ipairs(self.records) do
			love.graphics.setColor(get_draw_color_by_rank(rank))
			
			font.print('big', r.player, self.x + 40, self.y + rank * 30 + 40)
			font.print('big', r.score, self.x + 180, self.y + rank * 30 + 40)
		end
	else
		love.graphics.setColor(255, 0, 0)
		font.print('big', 'Get rank list failed', self.x + 40, self.y + 100)
	end
end

function LeaderBoardClient:update(dt)
	if not self.records and love.timer.getTime() - self.last_sync_time > 5 then
		self:sync()
	end
end
