require('misc')
require('stage')

stage_mgr = {}

local STAGE_DIR = 'stages'
local BACKUP_NAME_BASE = 'stages_backup'

local _stage_dir = ''
local _backup_dir = ''
local _stage_files = nil
local _stage_id = 1
local _lfs = love.filesystem

function stage_mgr.init(stage_dir)
	_stage_dir = stage_dir or STAGE_DIR
	_backup_dir = BACKUP_NAME_BASE .. '-' .. os.date('%m%d-%H%M%S')
	stage_mgr._scan_files()	
end

function stage_mgr._scan_files()
	_stage_files = list_filepath(_stage_dir)
	if _stage_id > #_stage_files then
		_stage_id = #_stage_files
	end
	table.sort(_stage_files)
end

function stage_mgr.gen_snapshot()
	return {
		stage_id = _stage_id,
	}
end

function stage_mgr.apply_snapshot(s)
	if not s then return end

	_stage_id = s.stage_id
	stage_mgr._scan_files()
end

function stage_mgr.load_current()	
	local file = _stage_files[_stage_id]
	local s = love.filesystem.read(file)
	if not s then
		printf('load stage from %s failed', file)
		return
	end
	local board, blocks, move = stage.load_by_str(s)
	if not board then
		print(string.format('parse stage file %s failed', file))
		return
	end

	return board, blocks, move
end

function stage_mgr.stage_file()
	return _stage_files[_stage_id]
end

function stage_mgr.move_to_prev_stage()
	_stage_id = _stage_id - 1
	if _stage_id < 1 then
		_stage_id = #_stage_files
	end	
end

function stage_mgr.move_to_next_stage()
	_stage_id = _stage_id + 1
	if _stage_id > #_stage_files then
		_stage_id = 1
	end
end

function stage_mgr.stage_total()
	return #_stage_files
end

function stage_mgr.stage_id(...)
	return _stage_id
end

function stage_mgr.del()
	local from = _stage_files[_stage_id]
	local to = _backup_dir .. '/' .. from:gsub('/', '-')
	copy_file(from, to)
	local absolute_from = 'block/' .. from
	os.remove(absolute_from)	
	stage_mgr._scan_files()
end
