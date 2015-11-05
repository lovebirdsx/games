require('state_manager')
require('misc')

StageSelect = class(state)

function StageSelect:_create_stages(path)
	local stages = {}
	local dirs = list_dirs(path)
	table.sort(dirs)
	for _, dir in ipairs(dirs) do
		
	end

	return stages
end

function StageSelect:init()	
	self.stages = self:_create_stages()	
end

function StageSelect:update(dt)
	
end

function StageSelect:draw()
	
end

function StageSelect:keypressed(key)

end

function StageSelect:mousepressed(x, y, button)
	-- body
end
