require('state_manager')
require('leader_board_cl')
require('event_dispatcher')

SendRecord = class(State, function (self, score)
	self.score = score or 0
	self.player = ''	

	local ed = EventDispatcher:instance()
	ed:add('keypressed', self, self.keypressed)
end)

function SendRecord:exit()
	local ed = EventDispatcher:instance()
	ed:remove('keypressed', self, self.keypressed)
end

function SendRecord:update(dt)
	LeaderBoardClient:instance():update(dt)
end

function SendRecord:draw()
	LeaderBoardClient:instance():draw()	
	love.graphics.setColor(255, 255, 255, 255)
	font.print('big', string.format('Your last play score: %g\nPlease enter your name and press enter to commit', self.score)
		, 400, 100)
	font.print('big', self.player, 440, 180)

	if self.tips then
		love.graphics.setColor(0, 255, 0, 255)
		font.print('big', self.tips, 400, 300)
	end

	if self.warning then
		love.graphics.setColor(255, 0, 0, 255)
		font.print('big', self.warning, 400, 300)
	end
end

function SendRecord:commit()
	self.warning = nil
	local lb = LeaderBoardClient:instance()	
	if lb:add(self.player, self.score) then
		lb:sync()		
		self.tips = 'Commit succeed :)\nPress enter to contine'
		self.commit_ok = true
	else
		self.warning = 'Commit failed, please try again later...'
	end	
end

function SendRecord:keypressed(key)
	local k = string.match(key, '^[%w-]$')
	if k then
		if self.player == '' then
			k = string.match(k, '[%a]')
		end
		if k and self.player:len() < 12 then
			self.player = self.player .. k
		end
	end

	if key == 'return' then
		if not self.commit_ok then
			self:commit()
		else
			StateManager:instance():change_state('EndlessPlay')
		end
	elseif key == 'backspace' then
		self.player = self.player:sub(1, -2)
	end
end
