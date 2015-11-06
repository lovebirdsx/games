require('class')

local instance

EventDispatcher = class(function (self)
	self.msg_map = {}
end)

function EventDispatcher:instance()
	if not instance then
		instance = EventDispatcher()
	end

	return instance
end

function EventDispatcher:add(type, obj, fun)
	local map = self.msg_map[type]
	if not map then
		map = {}
		self.msg_map[type] = map
	end

	table.insert(map, {obj = obj, fun = fun})
end

function EventDispatcher:remove(type, obj, fun)
	local map = self.msg_map[type]
	for i, ent in ipairs(map) do
		if ent.obj == obj and ent.fun == fun then
			table.remove(map, i)
			return
		end
	end
end

function EventDispatcher:send(t, ...)
	local map = self.msg_map[t]
	if map then
		for _, ent in ipairs(map) do			
			ent.fun(ent.obj, ...)
		end
	end
end
