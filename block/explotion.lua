require('sound')
require('row_explotion')

explotion = {}

function explotion.create(line_up_result)
	local self = {}
	local row_id = 1
	local row_ex = nil

	function self._start_row_explotin(r)		
		sound.play('row' .. r)
		row_id = r
		row_ex = row_explotion.create(line_up_result[r])		
		row_ex.on_end(function ()
			self.row_ex_end_cb(r)
			if r < #line_up_result then
				self._start_row_explotin(r + 1)				
			else
				row_ex = nil				
				self.end_cb()
			end
		end)
	end

	function self.update(dt)
		if row_ex then
			row_ex.update(dt)
		end
	end

	function self.draw()
		if row_ex then
			row_ex.draw()
		end
	end

	function self.on_end(cb)
		self.end_cb = cb
	end

	function self.on_row_ex_end(cb)
		self.row_ex_end_cb = cb
	end

	function self.start()
		self._start_row_explotin(1)
	end

	return self
end