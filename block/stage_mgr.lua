require('misc')
require('stage')

stage_mgr = {}

local BACKUP_DIR = 'backup' -- .. os.date('%m%d-%H%M%S')

function stage_mgr.del(path)
	local from = path
	local to = BACKUP_DIR .. '/' .. get_file_name_by_path(path)
	copy_file(from, to)
	local absolute_from = 'block/' .. from
	os.remove(absolute_from)
	stage_mgr._scan_files()
end
