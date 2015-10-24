
function main()
	local c_send = love.thread.getChannel("send")

	while true do
		local a = c_send:demand()
		local b = c_send:demand()
		local f = foo(a, b)

		local c_recv = love.thread.getChannel("recv")
		c_recv:push(f)
	end
end

function foo(a, b)
	return a, b
end

main()
