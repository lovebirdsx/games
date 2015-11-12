require('class')
require('log')

State = class()

function State:exit()
	
end

function State:update(dt)

end

function State:draw()
	
end

local sm

StateManager = class(function(self)	
	self.states = {}
end)

function StateManager:instance()
	if not sm then sm = StateManager() end
	return sm
end

function StateManager:reg(state_name, constructor)
	self.states[state_name] = constructor
	debug('StateManager: reg %s', state_name)
	assert(constructor)
end

function StateManager:change_state(state_name, ...)
	if self.current_state then
		self.current_state:exit()
	end
	debug('StateManager: enter %s', state_name)
	local state = self.states[state_name](...)
	self.current_state = state	
end

function StateManager:exit()
	if self.current_state then self.current_state:exit() end
end

function StateManager:update(dt)
	self.current_state:update(dt)
end

function StateManager:draw()
	self.current_state:draw()
end


