require('misc')
require('stage')

stage_mgr = {}

local BACKUP_DIR = 'backup_' .. os.date('%m%d-%H%M%S')

local _lfs = love.filesystem

function stage_mgr.del()
	local from = _stage_files[_stage_id]
	local to = _backup_dir .. '/' .. from:gsub('/', '-')
	copy_file(from, to)
	local absolute_from = 'block/' .. from
	os.remove(absolute_from)	
	stage_mgr._scan_files()
end

stage_mgr._scan_files()