require('table_save')
require('stage')
require('misc')
require('lfs')

function cover_stage(from, to)
	local t = table.load(from)
	if t then
		write_file(to, serialize(t))
		printf('covert ok: %s', to)
	else
		printf('table.load %s failed', from)
	end
end

local function list_filepath(folder)
	local result = {}
	
	local function list_filepath_inner(result, folder)				
		for f in lfs.dir(folder) do
			if f ~= '.' and f ~= '..' then
				local path = folder .. '/' .. f			
				if lfs.attributes(path,'mode')== 'directory' then
					list_filepath_inner(result, path)
				elseif lfs.attributes(path,'mode') == 'file' then
					table.insert(result, path)
				end
			end
		end
	end
	list_filepath_inner(result, folder)
	return result
end

function main()
	for _, f in ipairs(list_filepath('stages')) do
		local from = f
		local to = 'output/' .. f
		cover_stage(from, to)
	end
end

function test()
	for _, f in ipairs(list_filepath('stages')) do
		print(f)
	end
end

main()