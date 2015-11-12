require('log')

function start_server(port, callback)
	local socket = require('socket')
	
	local server = assert(socket.bind('*', port))
	local ip, port = server:getsockname()	
	info('server start at ' .. port)
	
	-- loop forever waiting for clients
	while true do
		-- wait for a connection from any client
		local client = server:accept()
		-- make sure we don't block waiting for this client's line
		client:settimeout(10)
		-- receive the line
		local req, err = client:receive()

		-- if there was no error, send it back to the client
		if not err then
			local resp = callback(req)
			client:send(resp .. '\n')
		end

		-- done with client, close the object
		client:close()
	end
end
