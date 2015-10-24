require 'button'

--------------------------------------------------------------------------------
-- cheesy selector dealie:  < foo >
--------------------------------------------------------------------------------

Selector = class()

function Selector:init(items, x, y, font)
   self.x = x
   self.y = y
   self.font = font
   self.items = items

   self.width = 0   -- fit to longest item name
   for i,name in pairs(self.items) do
      self.width = math.max(self.width, font:getWidth(name))
   end

   local prev, next = '<', '>'
   local width, height = font:getWidth(prev), font:getHeight(prev)
   self.prev = Button:new(prev, self.x - width*2   , y, width*2, height*2, false)
   self.next = Button:new(next, self.x + self.width, y, width*2, height*2, false)

   self.prev.onClick = function() self:nextItem(-1) end
   self.next.onClick = function() self:nextItem( 1) end

   self.selected = 1
   print('Selector:init', self.items, self.selected)
end

function Selector:add(item)
   local index = #self.items + 1
   self.items[index] = item
   self.selected = index
end

function Selector:getSelected()
   return self.items[self.selected]
end

function Selector:nextItem(dir)
   if #self.items == 1 then return end
   self.selected = self.selected + (dir or 1)
   if self.selected > #self.items then self.selected = 1           end
   if self.selected < 1           then self.selected = #self.items end
   if self.onSelectionChanged then self:onSelectionChanged() end
end

function Selector:draw()
   love.graphics.setColor(200,200,200)
   love.graphics.printf(self.items[self.selected], self.x, self.y, self.width, 'center')
end
