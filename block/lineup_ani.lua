require('sound')
require('row_explotion')

lineup_ani = {}

function lineup_ani.create(rows)
	local self = {}
	local row_id = 0
	local row_ex = nil	

	function self._start_row_explotin(r_id)
		sound.play('row' .. r_id)
		row_ex = row_explotion.create(rows[r_id])		
		row_ex.on_end(function () row_ex = nil end)
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

	function self.is_end()
		return not row_ex
	end

	function self.type()
		return 'lineup'
	end	

	function self.start_next_row_explotion()
		row_id = row_id + 1
		if row_id <= #lineup_result then
			self._start_row_explotin(row_id)
			return true
		else
			return false
		end
	end

	return self
end
