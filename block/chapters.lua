require('game_saver')
require('config')
require('stage')
require('misc')

Chapter = class(function(self, dir)	
	local stage_files = list_filepath(dir)
	table.sort(stage_files)
	local stages = {}
	local stages_by_name = {}
	for _, path in ipairs(stage_files) do
		local stage = Stage(path)
		stages[#stages + 1] = stage
		stages_by_name[stage.name] = stage
	end

	self.stages = stages
	self.stages_by_name = stages_by_name
	self.name = get_file_name_by_path(dir)
	self.unlocked = false
end)

function Chapter:gen_snapshot()
	local s = {}
	local stages = {}
	for name, stage in pairs(self.stages_by_name) do
		s[name] = stage:gen_snapshot()
	end

	s.stages = stages
	s.unlocked = self.unlocked
	return s
end

function Chapter:apply_snapshot(s)
	for name, stage_snapshot in pairs(s.stages) do
		self.stages_by_name[name]:apply_snapshot(stage_snapshot)
	end
	self.unlocked = s.unlocked
end

function Chapter:is_passed()
	for _, stage in ipairs(self.stages) do
		if not stage.is_passed then
			return false
		end
	end
	return true
end

function Chapter:unlock()
	self.unlocked = true
	self.stages[1]:unlock()
end

Chapters = class(function(self, dir)
	local chapter_dirs = list_dirs(dir)
	table.sort(chapter_dirs)
	local chapters = {}
	local chapters_by_name = {}
	for _, chapter_dir in ipairs(chapter_dirs) do
		local chapter = Chapter(chapter_dir)		
		chapters[#chapters + 1] = chapter
		chapters_by_name[chapter.name] = chapter
	end
	self.chapters = chapters
	self.chapters_by_name = chapters_by_name
end)

local instance
function Chapters:instance()
	if not instance then
		instance = Chapters(config.chapter_dir)
	end
	return instance
end

function Chapters:load()
	local chapters = GameSaver:instance():get('Chapters')
	if chapters then
		for chapter_name, snapshot in pairs(chapters) do
			local chapter = self.chapters_by_name[chapter_name]
			chapter:apply_snapshot(snapshot)
		end
	else
		local ch1 = self.chapters[1]
		ch1:unlock()
	end
end

function Chapters:save()
	local save = {}
	for _, chapter in ipairs(self.chapters) do
		save[chapter.name] = chapter:gen_snapshot()
	end
	GameSaver:instance():set('Chapters', save)
end
