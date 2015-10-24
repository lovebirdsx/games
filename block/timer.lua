require('timer_mgr')

timer = {}

function timer.create()
	local self = {}
	local _t = 0
	local _total = 0
	local _stopped = false
	local _cb = nil
	local _loop = false
	local _interval = 0

	function self.start(interval, loop, cb)
		_interval = interval
		_loop = loop
		_cb = cb

		timer_mgr.add(self)
	end

	function self.update(dt)
		if _stopped then return end

		_t = _t + dt
		_total = _total + dt
		if _t > _interval then
			if _loop then
				_t = _t - _interval
				_cb(_total)
			else
				_stopped = true
				_cb(_total)
			end
		end
	end

	function self.is_end()
		return _stopped
	end

	function self.stop()
		_stopped = true
	end	

	

	return self
end
