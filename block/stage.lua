require('stage_loader')
require('class')
require('log')

Stage = class(function(self, path)
	self.path = path
	self.name = get_file_name_by_path(path)
	self.is_passed = false
	self.is_unlocked = false
	self.is_loaded = false
end)

function Stage:load()
	if not self.is_loaded then
		debug('Stage: load %s', self.path)
		self.board, self.blocks, self.best_move = stage_loader.load(self.path)
		if not self.board then
			warning('Stage: load %s failed', self.path)
			return false
		else
			self.is_loaded = true
		end		
	end
	return true
end

function Stage:pass()
	self.is_passed = true
end

function Stage:unlock()
	self.is_unlocked = true
end

function Stage:gen_snapshot()
	local s = {}
	s.is_passed = self.is_passed
	s.is_unlocked = self.is_unlocked

	return s
end

function Stage:apply_snapshot(s)
	self.is_passed = s.is_passed
	self.is_unlocked = s.is_unlocked
end
