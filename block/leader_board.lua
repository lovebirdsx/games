require('class')
require('game_saver')
require('log')

local MAX_RECORD = 14

LeaderBoard = class(function (self, path)
	self.path = path
	self.max_record = MAX_RECORD
	self.record_id = 0
	self.records = {}
	self.saver = GameSaver(path)
	self:load()
end)

function LeaderBoard:set_max_record(count)
	self.max_record = count
end

function LeaderBoard:load()
	self.saver:load()
	local cfg = self.saver:get('LeaderBoard')
	if cfg then
		self.records = cfg.records
		self.max_record = cfg.max_record
		self.record_id = cfg.record_id

		info('LeaderBoard: max_record = %d curr_record = %d', self.max_record, #self.records)
	else
		local default_record_name = {'Foo', 'Bar', 'Bala', 'Hello', 'World', 'Test',
			'Enter', 'Exit', 'Init', 'Update', 'Draw', 'Load', 'Save', 'Print'}
		for i, name in ipairs(default_record_name) do
			self:add(name, i * 100)
		end
	end
end

function LeaderBoard:save()
	local cfg = {
		records = self.records,
		max_record = self.max_record,
		record_id = self.record_id,
	}
	self.saver:set('LeaderBoard', cfg)
	self.saver:save()
end

function LeaderBoard:add(player, score)
	self.records[#self.records + 1] = {player = player, score = score, id = self.record_id}
	table.sort(self.records, function (a, b)
		if a.score ~= b.score then
			return a.score > b.score
		else
			return a.id < b.id
		end
	end)

	if #self.records > self.max_record then
		for i = self.max_record + 1, #self.records do
			self.records[i] = nil
		end
	end

	self.record_id = self.record_id + 1	
end

function LeaderBoard:get_all()
	return self.records
end

function LeaderBoard:output()
	for i, r in ipairs(self.records) do
		print(r.player, r.score)
	end
end
