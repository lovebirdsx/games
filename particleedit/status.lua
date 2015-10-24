require 'button'


--------------------------------------------------------------------------------
-- Labeled computed value. Implement getText to return computed value.
--------------------------------------------------------------------------------

Indicator = class()

function Indicator:init(label, font, x, y)
   self.x = x
   self.y = y
   self.label = label
   self.font = font
   self.valuex = x + font:getWidth(label) + 5
   self.width = self.valuex + 100 - self.x
end

function Indicator:draw()
   love.graphics.setFont(self.font)
   love.graphics.print(self.label, self.x, self.y)
   love.graphics.print(self:getValue(), self.valuex, self.y)
end


--------------------------------------------------------------------------------
-- status text
--------------------------------------------------------------------------------

Status = class()

function Status:init(x, y)
   self.x = x 
   self.y = y
   self.timeout = 0
end

function Status:show(timeout, ...)
   self.timeout = timeout or 5
   self.text = string.format(...)
end

function Status:update(dt)
   if self.timeout > 0 then
      self.timeout = self.timeout - dt
   end
end

function Status:draw()
   if self.timeout > 0 then
      local alpha = (self.timeout > 1) and 255 or (255 * self.timeout)
      love.graphics.setColor(255, 255, 0, alpha)
      love.graphics.print(self.text, self.x, self.y)
   end
end
