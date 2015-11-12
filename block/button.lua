require('event_dispatcher')
require('class')
require('font')
require('log')

Button = class(
   function (self, text, x, y, width, height)
      self.text = text
      self.x = x
      self.y = y
      self.width = width
      self.height = height
      self.visible = true
      self.font_type = 'big'
      self.color = {
         normal  = { 200, 200, 200 },
         hover   = { 255, 255,   0 },
         pressed = { 200, 200,   0 },
      }
   end
)

function Button:mousemoved(x, y)
   self.hover = self:test_point(x, y)
end

function Button:mousepressed(x, y)
   self.pressed = self.hover      
end

function Button:mousereleased(x, y)   
   if self.pressed and self.hover then
      debug('[%s] clicked', self.text)      
      self:on_click()      
   end

   self.pressed = false
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
   font.print(self.font_type, self.text, self.x + 2, self.y + 2)
   love.graphics.setColor(unpack(color))
   font.print(self.font_type, self.text, self.x + pop, self.y + pop)
end

Buttons = class(function (self)
   self.buttons = {}
   self.visible = true
   local ed = EventDispatcher:instance()
   ed:add('mousemoved', self, self.mousemoved)
   ed:add('mousepressed', self, self.mousepressed)
   ed:add('mousereleased', self, self.mousereleased)
end)

-- must called manally when buttons no need any more
function Buttons:release()
   local ed = EventDispatcher:instance()
   ed:remove('mousemoved', self, self.mousemoved)
   ed:remove('mousepressed', self, self.mousepressed)
   ed:remove('mousereleased', self, self.mousereleased)
end

function Buttons:add(button)
   self.buttons[#self.buttons + 1] = button
end

function Buttons:remove(button)
   for i, b in ipairs(self.buttons) do
      if b == button then
         table.remove(self.buttons, i)
         break
      end
   end
end

function Buttons:mousemoved(x, y, dx, dy)
   if not self.visible then return end

   for i,button in ipairs(self.buttons) do
      button:mousemoved(x, y)
   end
end

function Buttons:mousereleased(x, y, b)
   if not self.visible then return end

   if b == 'l' then
      for i,button in ipairs(self.buttons) do
         button:mousereleased(x, y)
      end
   end
end

function Buttons:mousepressed(x, y, b)
   if not self.visible then return end

   if b == 'l' then
      for i,button in ipairs(self.buttons) do
         button:mousepressed(x, y)
      end
   end
end

function Buttons:draw()
   if not self.visible then return end

   for i,button in ipairs(self.buttons) do
      button:draw()
   end
end

function Buttons:count()
   return #self.buttons
end

function Buttons:get_button(id)
   return self.buttons[id]
end

function Buttons:get_button_at_pos(x, y)
   for i, b in ipairs(self.buttons) do
      if b:test_point(x, y) then
         return b
      end
   end
end

function Buttons:hide()
   self.visible = false
end

function Buttons:show()
   self.visible = true
end
