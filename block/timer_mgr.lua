timer_mgr = {}

local timers = nil

function timer_mgr.init()
	timers = {}
end

function timer_mgr.add(timer)
	table.insert(timers, timer)
end

function timer_mgr.remove(timer)
	for i, t in ipairs(timers) do
		if t == timer then
			table.remove(timers, i)
			return
		end
	end
end

function timer_mgr.update(dt)
	local remove = {}
	for _, t in ipairs(timers) do
		t.update(dt)
		if t.is_end() then
			table.insert(remove, t)
		end
	end

	for _, t in ipairs(remove) do
		timer_mgr.remove(t)
	end
end