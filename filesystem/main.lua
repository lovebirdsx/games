function love.load()
	filesString = recursiveEnumerate("", "")
end
 
-- This function will return a string filetree of all files
-- in the folder and files in all subfolders
function recursiveEnumerate(folder, fileTree)
	local lfs = love.filesystem
	local filesTable = lfs.getDirectoryItems(folder)
	for i,v in ipairs(filesTable) do
		local file = folder.."/"..v
		if lfs.isFile(file) then
			fileTree = fileTree.."\n"..file
		elseif lfs.isDirectory(file) then
			fileTree = fileTree.."\n"..file.." (DIR)"
			fileTree = recursiveEnumerate(file, fileTree)
		end
	end
	return fileTree
end
 
function love.draw()
	love.graphics.print(filesString, 0, 0)
end