require 'button'

--------------------------------------------------------------------------------
-- row of buttons along right side of screen
--------------------------------------------------------------------------------

toolbar = {
   x = love.graphics.getWidth()-100,
   y = 2,
   width = 100,
   height = 25,
   spacing = 10,
   hotkeys = {}
}

function toolbar:add(name, hotkey, action)
   local button = Button:new(name, self.x, self.y, self.width, self.height)
   button.onClick = action
   if hotkey then
      self.hotkeys[hotkey] = button
   end
   self.y = self.y + self.height
   return button
end

function toolbar:onKeyPressed(key)
   local button = self.hotkeys[key]
   if button then button:onClick() end
end

function toolbar:addSpacer()
   self.y = self.y + self.spacing
end
