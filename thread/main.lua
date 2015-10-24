local thread, c_send, c_recv

-- main.lua
function love.load()
   thread = love.thread.newThread("thread.lua")
   c_send = love.thread.getChannel("send")
   c_recv = love.thread.getChannel("recv")
   thread:start()   
end

local a, b = 1, 2
function love.keypressed(key)
	c_send:push(a)
	c_send:push(b)
	a = a + 1
	b = b + 1
	local c = c_recv:demand()
	print(string.format('foo(%d, %d) = %d', a, b, c))
end

function love.update(dt)
   
end

function love.draw()
		
end
