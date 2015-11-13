require('class')
require('log')
require('config')
require('misc')

GameSaver = class(function (self, path, version)
	self.path = path
	self.version = version
	self.data = {}
end)

local instance

function GameSaver:instance()
	if not instance then		
		instance = GameSaver(config.save_file, config.version)		
	end

	return instance
end

function GameSaver:load()
	local s = love.filesystem.read(self.path)
	if not s then
		warning('GameSaver: open file %s failed', self.path)
		return
	end

	local data = unserialize(s)
	if not data then
		warning('GameSaver: unserialize %s failed', self.path)
		return
	end

	if data.version ~= self.version then
		warning('GameSave: save version [%s] not equal to [%s]', data.version, self.version)
		return
	end

	self.data = data
	info('GameSave: load %s ok', self.path)
end

function GameSaver:save()
	self.data.version = self.version
	local s = serialize(self.data)
	if not love.filesystem.write(self.path, s) then
		warning('GameSaver: save to %s failed', self.path)
	else
		info('GameSaver: save to %s succeed', self.path)
	end
end

function GameSaver:get(k)
	return self.data[k]
end

function GameSaver:set(k, v)
	self.data[k] = v
end
