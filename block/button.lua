require 'class'

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
end

function Button:mousemoved(x, y)
   self.hover = self:test_point(x, y)
end

function Button:mousepressed(x, y)
   self.pressed = self.hover
end

function Button:mousereleased(x, y)
   self.pressed = self.hover
   if self.pressed then
      self.pressed = false
      self:on_click()
   end
end

function Button:show()
   self.visible = true
end

function Button:hide()
   self.visible = false
end

function Button:test_point(x, y)
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

Buttons = class()

function Buttons:init()
   self.buttons = {}
end

function Buttons:add(button)
   self.buttons[#self.buttons + 1] = button
end

function Buttons:mousemoved(x, y)
   for i,button in ipairs(self.buttons) do
      button:mousemoved(x, y)
   end
end

function Buttons:mousereleased(x, y)
   for i,button in ipairs(self.buttons) do
      button:mousereleased(x, y)
   end
end

function Buttons:mousepressed(x, y)
   for i,button in ipairs(self.buttons) do
      button:mousepressed(x, y)
   end
end

function Buttons:draw()
   for i,button in ipairs(self.buttons) do
      button:draw()
   end
end
