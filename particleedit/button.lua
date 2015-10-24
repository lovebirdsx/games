require 'class'

--------------------------------------------------------------------------------
-- crude Button class
--------------------------------------------------------------------------------

Button = class()

function Button:init(text, x, y, width, height)
   self.text = text
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.visible = true
   self.color = {
      normal  = { 200, 200, 200 },
      hover   = { 255, 255,   0 },
      pressed = { 200, 200,   0 },
   }
   buttons:add(self)
end

function Button:update(x, y)
   self.hover = self:pointInButton(x, y)
end

function Button:onMouseDown(x, y)
   self.pressed = self.hover
end

function Button:onMouseUp(x, y)
   self.pressed = self.hover
   if self.pressed then
      self.pressed = false
      self:onClick()
   end
end

function Button:show()
   self.visible = true
end

function Button:hide()
   self.visible = false
end

function Button:pointInButton(x, y)
   return self.visible
      and x >= self.x and x <= self.x + self.width
      and y >= self.y and y <= self.y + self.height
end

function Button:draw()
   if not self.visible then return end
   local color = self.pressed and self.color.pressed
              or self.hover   and self.color.hover
              or self.color.normal
   local pop = self.pressed and 1 or 0
   love.graphics.setColor(0, 0, 0)
   love.graphics.printf(self.text, self.x + 2, self.y + 2, self.width + pop, 'center')
   love.graphics.setColor(unpack(color))
   love.graphics.printf(self.text, self.x + pop, self.y + pop, self.width + pop, 'center')
end

--------------------------------------------------------------------------------
-- button manager, routes events to buttons
--------------------------------------------------------------------------------

buttons = {}

function buttons:add(button)
   self[#self + 1] = button
end

function buttons:update(mousex, mousey)
   for i,button in ipairs(self) do
      button:update(mousex, mousey)
   end
end

function buttons:onMouseUp(x, y)
   for i,button in ipairs(self) do
      button:onMouseUp(x, y)
   end
end

function buttons:onMouseDown(x, y)
   for i,button in ipairs(self) do
      button:onMouseDown(x, y)
   end
end

function buttons:draw()
   for i,button in ipairs(self) do
      button:draw()
   end
end
