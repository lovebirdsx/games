require 'status'
require 'toolbar'
require 'particles'
require 'settings'

-- gobals shared with 'settings.lua'
system = nil -- the particle system we're editing
status = nil -- status message
fontSmall = nil
fontNormal = nil

local gfx, mouse = love.graphics, love.mouse
local imageSelect, modeSelect, blendmode, framerate, partcount

function restartSystem()
   system:reset()
   system:start()
end

function love.mousepressed(x, y, button)
   buttons:onMouseDown(x, y, button)

   if button == 'r' then
      config.x, config.y = x, y
      settings:apply()
      restartSystem()
   elseif button == 'wd' or button == 'wu' and x < menuWidth and y <= menuSpacing * #settings then
      local adjustment = adjustRate
      if button == 'wd' then
         adjustment = adjustment * -1
      end
      local index = math.floor(y / menuSpacing) + 1
      settings:adjust(index, adjustment)
   end
end

function love.mousereleased(x, y, button)
   buttons:onMouseUp(x, y, button)
end

function getConfigs()
   local configs = {}
   for i,file in pairs(love.filesystem.getDirectoryItems('.')) do
      if file:match(filenameMatchTemplate) then
         table.insert(configs, file)
      end
   end
   -- none on disk, creaate a new one and write it
   if #configs == 0 then
      configs[#configs+1] = os.date(filenameWriteTemplate)
      settings:write(configs[#configs])
   end
   return configs
end

function love.load()
   print(love.graphics.getRendererInfo())
   print('canvas:', love.graphics.isSupported('canvas'))
   love.filesystem.setIdentity('ParticleEdit/')

   fontSmall  = gfx.newFont(12)
   fontNormal = gfx.newFont(12)
   gfx.setFont(fontNormal)

   local menuEdgeX = menuWidth + 80

   status = Status:new(menuEdgeX, gfx.getHeight() - 55)

   imageSelect = ParticleSelector:new(menuEdgeX, 0, fontNormal)
   function imageSelect:onSelectionChanged()
      system:setImage(imageSelect:getSelected())
   end

   modeSelect = Selector:new({'additive', 'alpha'}, imageSelect.x + imageSelect.width + 100, 0, fontNormal)
   function modeSelect:onSelectionChanged()
      blendmode = modeSelect:getSelected()
   end

   configSelect = Selector:new(getConfigs(), modeSelect.x + modeSelect.width + 100, 0, fontNormal)
   function configSelect:onSelectionChanged()
      settings:read()
      settings:apply()
      system:setBufferSize(config.buffer_size)
      restartSystem()
   end

   local indicatorY = gfx. getHeight() - fontSmall:getHeight() - 10

   framerate = Indicator:new('FPS:', fontSmall, menuEdgeX, indicatorY)
   framerate.getValue = love.timer.getFPS

   partcount = Indicator:new('particles:', fontSmall, framerate.x + framerate.width, indicatorY)
   function partcount:getValue()
      return system:getCount()
   end

   toolbar:add('Restart', ' ',      function() restartSystem()                   end)
   toolbar:addSpacer(5)
   toolbar:add('Save',    's',      function() settings:save()                   end)
   toolbar:add('Copy',    nil,      function() settings:copy()                   end)
   toolbar:add('Revert',  nil,      function() configSelect:onSelectionChanged() end)
   toolbar:add('Delete',  nil,      function() settings:delete()                 end)
   toolbar:addSpacer(5)
   toolbar:add('Quit',    'escape', function() os.exit()                         end)

   system = gfx.newParticleSystem(imageSelect:getSelected(), 10)
   settings:apply()

   modeSelect:onSelectionChanged()
   configSelect:onSelectionChanged()
end

function love.keypressed(key)
       if key == '1' then adjustRate = 1
   elseif key == '2' then adjustRate = 10
   elseif key == '3' then adjustRate = 100
   elseif key == '4' then adjustRate = 1000
   elseif key == '5' then adjustRate = .1
   elseif key == '6' then adjustRate = .01
   else toolbar:onKeyPressed(key) end
end

function love.update(dt)
   local x, y = mouse.getPosition()
   if mouse.isDown 'l' and x > menuWidth and x < (toolbar.x - 20) and y > 50 then
      config.x, config.y = x, y
      settings:apply()
   end
   buttons:update(x, y)
   status:update(dt)
   system:update(dt)
end

function love.draw()
   gfx.setBlendMode(blendmode)
   gfx.draw(system, 0, 0)

   gfx.setBlendMode('alpha')
   gfx.setFont(fontSmall)
   framerate:draw()
   partcount:draw()

   gfx.setFont(fontNormal)
   settings:draw()
   status:draw()
   buttons:draw()
   modeSelect:draw()
   imageSelect:draw()
   configSelect:draw()
end
