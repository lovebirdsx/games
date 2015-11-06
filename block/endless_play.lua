require('state_manager')
require('play')
require('button')
require('event_dispatcher')
require('game_saver')

EndlessPlay = class(State, function (self)
	self.play = Play()
	self.buttons = Buttons()	

	local block_generator = self.play.block_generator
	block_generator:set_max_block_count(3)
	block_generator:fill_all()
	block_generator:set_pos(700, 150)
	block_generator:set_can_refill(false)

	local ed = EventDispatcher:instance()
	ed:add('mousepressed', self, self.mousepressed)

	local screen_w = love.graphics.getWidth()
	local back_button = Button('Back', screen_w - 100, 20, 100, 50)
	back_button.on_click = function ()		
		local sm = StateManager:instance()		
		sm:change_state('ModeSelect')
	end

	self.buttons:add(back_button)

	self:load()

	self.play:on_end(function ()		
		if self.play.score > self.highscore then
			self.highscore = self.play.score
			self.is_highscore = true
		end
	end)
end)

function EndlessPlay:load()
	local cfg = GameSaver:instance():get('EndlessPlay')
	if cfg then
		self.highscore = cfg.highscore
	else
		self.highscore = 0
	end
end

function EndlessPlay:save()
	local cfg = {}
	cfg.highscore = self.highscore
	GameSaver:instance():set('EndlessPlay', cfg)
end

function EndlessPlay:exit()
	local ed = EventDispatcher:instance()
	ed:remove('mousepressed', self, self.mousepressed)

	self.buttons:release()
	self:save()
end

function EndlessPlay:update(dt)
	self.play:update(dt)
end

function EndlessPlay:draw()
	self.play:draw()
	self.buttons:draw()
	font.print('hurge', string.format('%d', self.play.score), 400, 10)
	font.print('big', string.format('Best: %d', self.highscore), 30, 10)

	if self.play:is_end() then
		love.graphics.setColor(0, 0, 0, 192)
		love.graphics.rectangle('fill', 0, 0, 
			love.window.getWidth(), love.window.getHeight())
		
		if self.is_highscore then
			love.graphics.setColor(123, 212, 57, 255)
			font.print('hurge', string.format('High score: %d !', self.highscore), 300, 250)
		else
			love.graphics.setColor(255, 20, 20, 255)
			font.print('hurge', 'GameOver', 350, 250)
		end
	end
end

function EndlessPlay:restart()
	self.play:reset()
	self.is_highscore = false
end

function EndlessPlay:mousepressed(button, x, y)
	if self.play:is_end() then
		if button == 'l' then
			self:restart()
		end
	end
end
