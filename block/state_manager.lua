require('class')

State = class()

function State:enter()
	-- body
end

function State:exit()
	-- body
end

function State:update(dt)

end

function State:draw()
	
end

function State:mousepressed(x, y, button)

end

function State:mousemoved(x, y, dx, dy)

end

function State:mousereleased(x, y, button)

end

function State:keypressed(key)
	
end

StateManager = class()

local _sm

function StateManager:instance()
	if not _sm then _sm = StateManager:new() end
	return _sm
end

function StateManager:init()
	
end

function StateManager:start(state)
	self.state = state
	self.state:enter()
end

function StateManager:exit()
	if self.state then self.state:exit() end
end

function StateManager:update(dt)
	self.state:update(dt)
end

function StateManager:draw()
	self.state:draw()
end

function StateManager:change_state(State)
	self.state:exit()
	self.state = State
	self.state:enter()
end

function StateManager:mousepressed(x, y, button)
	self.state:mousepressed(x, y, button)
end

function StateManager:mousemoved(x, y, dx, dy)
	self.state:mousemoved(x, y, dx, dy)
end

function StateManager:mousereleased(x, y, button)
	self.state:mousereleased(x, y, button)
end

function StateManager:keypressed(key)
	self.state:keypressed(key)
end
