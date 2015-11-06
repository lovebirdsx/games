function list_filepath(folder)
    if not love then error('can only use in love2d') end

	local result = {}
	
	local function list_filepath_inner(result, folder)		
		local lfs = love.filesystem
		local files = lfs.getDirectoryItems(folder)
		for _, f in ipairs(files) do			
			local path = folder .. '/' .. f			
			if lfs.isDirectory(path) then
				list_filepath_inner(result, path)
			elseif lfs.isFile(path) then
				table.insert(result, path)
			end		
		end
	end
	list_filepath_inner(result, folder)
	return result
end

-- return dir list in folder(include folder name)
function list_dirs(folder)
   if not love then error('can only use in love2d') end

    local result = {}
    local lfs = love.filesystem
    local files = lfs.getDirectoryItems(folder)
    for _, f in ipairs(files) do
        local path = folder .. '/' .. f
        if lfs.isDirectory(path) then
            table.insert(result, f)
        end
    end
    
    return result 
end

function get_dir(str,sep)
    sep = sep or'/'
    return str:match("(.*"..sep..")")
end

function copy_file(from, to)
    if not love then error('can only use in love2d') end

    local lfs = love.filesystem
    local content = lfs.read(from)
    if not content then
        printf('copy failed: read file %s failed', from)
    end

    local to_dir = get_dir(to)
    if not lfs.exists(to_dir) then
        lfs.createDirectory(to_dir)
    end

    lfs.write(to, content)    
end

function serialize(obj)  
    local lua = ""  
    local t = type(obj)  
    if t == "number" then  
        lua = lua .. obj  
    elseif t == "boolean" then  
        lua = lua .. tostring(obj)  
    elseif t == "string" then  
        lua = lua .. string.format("%q", obj)  
    elseif t == "table" then  
        lua = lua .. "{\n"  
    for k, v in pairs(obj) do  
        lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"  
    end  
    local metatable = getmetatable(obj)  
        if metatable ~= nil and type(metatable.__index) == "table" then  
        for k, v in pairs(metatable.__index) do  
            lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"  
        end  
    end  
        lua = lua .. "}"  
    elseif t == "nil" then  
        return nil  
    else  
        error("can not serialize a " .. t .. " type.")  
    end  
    return lua  
end  
  
function unserialize(lua)
    local t = type(lua)  
    if t == "nil" or lua == "" then  
        return nil  
    elseif t == "number" or t == "string" or t == "boolean" then  
        lua = tostring(lua)  
    else  
        error("can not unserialize a " .. t .. " type.")  
    end  
    lua = "return " .. lua  
    local func = loadstring(lua)  
    if func == nil then  
        return nil  
    end
    return func()  
end

function write_file(filepath, str)
    if love then
        love.filesystem.write(filepath, str)
    else
    	local f, err = io.open(filepath, 'w+')
    	if not f then
    		printf('write_file %s failed: %s', filepath, err)
            return
    	end
    	f:write(str)
    	f:close()
    end
end

function read_file(filepath)
    if love then
        return love.filesystem.read(filepath)
    else
        local f, err = io.open(filepath)
        if not f then
            printf('read_file %s failed: %s', filepath, err)
        end
        return f:read('*all')
    end	
end

function printf(fmt, ...)
	print(string.format(fmt, ...))
end
