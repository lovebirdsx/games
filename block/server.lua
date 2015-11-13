require('log')
require('config')

function start_server(port, callback)
	local socket = require('socket')
	
	local server = assert(socket.bind('*', port))
	local ip, port = server:getsockname()	
	info('server start at %s:%g', ip, port)
	
	while true do
		local client = server:accept()
		client:settimeout(config.timeout)
		local req, err = client:receive()
		if not err then
			local resp = callback(req)
			if resp then
				info('server: receive [%s] from %s:%g', req, client:getsockname())
				client:send(resp .. '\n')
			else
				warning('server: unknown req[%s] from %s:%g', req, client:getsockname())
			end
		else
			warning('server: error when receive from %s:%g', client:getsockname())
		end

		client:close()
	end
end
