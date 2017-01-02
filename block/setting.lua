require('class')
require('game_saver')
require('log')

Setting = class(function (self)
	self.log_level = 'info'
	self.sound_volume = 1
end)

local instance

function Setting:instance()
	if not instance then
		instance = Setting()
	end
	return instance
end

function Setting:load()
	local cfg = GameSaver:instance():get('Setting')
	if cfg then
		self:set_log_level(cfg.log_level)
		self:set_sound_volume(cfg.sound_volume)
	end
end

function Setting:save()
	local cfg = {
		log_level = self.log_level,
		sound_volume = self.sound_volume
	}

	GameSaver:instance():set('Setting', cfg)
end

function Setting:set_log_level(level)
	debug('Setting: log level set to [%s]', level)
	set_log_level(level)
	self.log_level = level	
end

function Setting:set_sound_volume(volume)
	debug('Setting: sound volume set to %g', volume)
	love.audio.setVolume(volume)
	self.sound_volume = volume
end

function Setting:troggle_sound()
	if self.sound_volume ~= 0 then
		self:set_sound_volume(0)
	else
		self:set_sound_volume(1)
	end
end
