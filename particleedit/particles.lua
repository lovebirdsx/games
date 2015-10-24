require 'selector'

-- edit this to add/remove particle images
local particles = {
   'fire.png',
   'cloud.png',
   '1.png',
   '2.png',
   '3.png',
   '4.png',
   '5.png',
   '6.png',
   '7.png',
   '8.png',
   '9.png',
   '10.png',
   '11.png',
   '12.png',
   '13.png',
   '14.png',
   '15.png',
   '16.png',
}

ParticleSelector = class(Selector)

function ParticleSelector:init(x, y, font)
   self.images = {}
   for i,name in pairs(particles) do
      self.images[name] = love.graphics.newImage(name)
   end
   self.super.init(self, particles, x, y, font)
end

function ParticleSelector:getSelected()
   return self.images[self.items[self.selected]]
end
