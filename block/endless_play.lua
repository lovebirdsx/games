require('state_manager')
require('play')
require('button')
require('event_dispatcher')
require('game_saver')
require('sound')

EndlessPlay = class(State, function (self)
	self.play = Play()
	self.buttons = Buttons()
	self.highscore = 0
	self.is_highscore = false

	local block_generator = self.play.block_generator
	block_generator:set_max_block_count(3)
	block_generator:fill_all()
	block_generator:set_pos(700, 150)

	local ed = EventDispatcher:instance()
	ed:add('mousepressed', self, self.mousepressed)

	local screen_w = love.graphics.getWidth()
	local back_button = Button('Back', screen_w - 100, 20, 100, 50)
	back_button.on_click = function ()
		local sm = StateManager:instance()
		sm:change_state('ModeSelect')
	end

	local restart_button = Button('Restart', screen_w - 100 - 80, 20, 100, 50)
	restart_button.on_click = function (b)
		self:restart()
	end

	self.buttons:add(back_button)
	self.buttons:add(restart_button)

	self:load()

	self.play:on_end(function ()		
		sound.stop('music')
		if self.play.score > self.highscore then
			self.highscore = self.play.score			
			self.is_highscore = true
			sound.play('highscore')
			sound.play('gameover')
		end		
	end)

	sound.play('music')
end)

function EndlessPlay:load()
	local cfg = GameSaver:instance():get('EndlessPlay')
	if cfg then
		self.highscore = cfg.highscore		
		self.play:apply_snapshot(cfg.play)
	end
end

function EndlessPlay:save()
	local cfg = {}
	cfg.highscore = self.highscore	
	cfg.play = self.play:gen_snapshot()
	GameSaver:instance():set('EndlessPlay', cfg)
end

function EndlessPlay:exit()
	local ed = EventDispatcher:instance()
	ed:remove('mousepressed', self, self.mousepressed)

	self.buttons:release()
	self.play:release()
	self:save()

	sound.stop('music')
end

function EndlessPlay:update(dt)
	self.play:update(dt)
end

function EndlessPlay:draw()
	self.play:draw()
	self.buttons:draw()
	love.graphics.setColor(255, 255, 255, 255)
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

function EndlessPlay:mousepressed(x, y, button)
	if self.play:is_end() then
		if button == 'l' then
			self:restart()
			sound.play('music')
		end
	end
end
