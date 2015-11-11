require('lfs')
require('log')

function list_filepath(folder)
    local result = {}
    local function helper(folder, result)        
        for file in lfs.dir(folder) do
            local path = folder .. '/' .. file
            if lfs.attributes(path, 'mode') == 'file' then
                result[#result + 1] = path
            elseif lfs.attributes(path, 'mode')== 'directory' then
                if file ~= '.' and file ~= '..' then
                    helper(path, result)
                end
            end
        end    
    end     

    helper(folder, result)
    return result
end

-- return dir list in folder(include folder name)
function list_dirs(folder)
    local result = {}
    
    for file in lfs.dir(folder) do
        local path = folder .. '/' .. file        
        if lfs.attributes(path, 'mode')== 'directory' then
            if file ~= '.' and file ~= '..' then
                table.insert(result, path)
            end
        end
    end

    return result   
end

function get_dir(str,sep)
    sep = sep or'/'
    return str:match("(.*"..sep..")")
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
	local f, err = io.open(filepath, 'w+')
	if not f then
		printf('write_file %s failed: %s', filepath, err)
        return false
	end
	f:write(str)
	f:close()
    return true
end

function read_file(filepath)
    local f, err = io.open(filepath)
    if not f then
        printf('read_file %s failed: %s', filepath, err)
        return
    end
    return f:read('*all')    
end

function copy_file(from, to)
    local content = read_file(from)
    write_file(to, content)
    os.remove(from)
end

function printf(fmt, ...)
	print(string.format(fmt, ...))
end

function get_file_name_by_path(path)
    local dir, file, ext = string.match(path, "(.-)([^\\/]-%.?([^%.\\/]*))$")
    return file
end
