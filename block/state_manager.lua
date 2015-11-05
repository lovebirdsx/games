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

StateManager = class()

local _sm

function StateManager:instance()
	if not _sm then _sm = StateManager() end
	return _sm
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
