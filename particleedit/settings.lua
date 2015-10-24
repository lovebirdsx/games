require 'template'
require 'util'

local gfx, mouse = love.graphics, love.mouse

menuWidth = 200
menuSpacing = 16
adjustRate = 1

configFiles = {}

-- indexed by number so we can iterate in fixed order
settings = {
   { name='x',                       value=gfx.getWidth() /2,    },
   { name='y',                       value=gfx.getHeight()/2,    },
   { name='x offset',                value=0,                    },
   { name='y offset',                value=0,                    },
   { name='buffer size',             value=2000, min=1,          },
	{ name='emission rate',           value=400,  min=0.5,        },
	{ name='lifetime',                value=-1,   min=-1,         },
	{ name='particle life',           value=5,    min=0.05,       },
   { name='size min',                value=1,    min=0,          },
   { name='size max',                value=3,    min=0,          },
   { name='size variation',          value=1,    min=0,  max=1   },
	{ name='speed min',               value=150                   },
   { name='speed max',               value=300,                  },
   { name='direction',               value=90,   min=0,  max=360 },
   { name='spread',                  value=360,  min=0,  max=360 },
   { name='spin min',                value=.5,   min=0,  max=360 },
   { name='spin max',                value=1,    min=0,  max=360 },
   { name='spin variation',          value=1,    min=0,  max=1   },
   { name='rotation min',            value=0,    min=0,  max=360 },
   { name='rotation max',            value=0,    min=0,  max=360 },
	{ name='tangential acceleration', value=0,                    },
	{ name='radial acceleration',     value=0,                    },
   { name='gravity min',             value=0,                    },
   { name='gravity max',             value=0,                    },
   { name='from red',                value=255,  min=0,  max=255 },
   { name='from green',              value=100,  min=0,  max=255 },
   { name='from blue',               value=0,    min=0,  max=255 },
   { name='from alpha',              value=0,    min=0,  max=255 },
   { name='to red',                  value=255,  min=0,  max=255 },
   { name='to green',                value=255,  min=0,  max=255 },
   { name='to blue',                 value=0,    min=0,  max=255 },
   { name='to alpha',                value=123,  min=0,  max=255 },
}

-- lookup index by escaped name (e.g. settings.x_offset == 3)
for index,setting in ipairs(settings) do 
   settings[setting.name:gsub(' ','_')] = index
end

-- proxy for directly accessing values
config = {}
setmetatable(config, config)
function config:__index   (key) return settings[settings[key]].value end
function config:__newindex(key, value) settings[settings[key]].value = value end

function settings:apply()
   local s = config
   system:setPosition( s.x, s.y )
   system:setOffset( s.x_offset, s.y_offset )
   system:setEmissionRate( s.emission_rate )
   system:setEmitterLifetime( s.lifetime )
   system:setParticleLifetime( s.particle_life )
   system:setColors( s.from_red, s.from_green, s.from_blue, s.from_alpha, s.to_red, s.to_green, s.to_blue, s.to_alpha )
   system:setSizes( s.size_min, s.size_max, s.size_variation )
   system:setDirection( math.rad(s.direction) )
   system:setSpeed( s.speed_min, s.speed_max  )
   system:setSpread( math.rad(s.spread) )
   system:setLinearAcceleration( s.gravity_min, s.gravity_max )
   system:setRotation( math.rad(s.rotation_min), math.rad(s.rotation_max) )
   system:setSpin( math.rad(s.spin_min), math.rad(s.spin_max), s.spin_variation )
   system:setRadialAcceleration( s.radial_acceleration )
   system:setTangentialAcceleration( s.tangential_acceleration )
end

function settings:adjust(settingIndex, adjustment)
   local setting = settings[settingIndex]

   setting.value = setting.value + adjustment
   if setting.max and setting.value > setting.max then setting.value = setting.max end
   if setting.min and setting.value < setting.min then setting.value = setting.min end

   -- special case for buffer size, because changing it resets the particle system
   if setting.name == 'buffer size' then
      system:setBufferSize(setting.value)
   else
      settings:apply()
   end
end

function settings:draw()
   local x, y, mx, my = 10, 0, mouse.getPosition()

   for i, setting in ipairs(settings) do
      local hover = mx < menuWidth and my >= y and my < y + menuSpacing

      -- text shadow
      gfx.setColor(0,0,0)
      gfx.print(setting.name,  x       + 1, y + 1)
      gfx.print(setting.value, x + 150 + 1, y + 1)

      if hover then
         gfx.setColor(104,176,255)
      elseif i >= settings.to_red then
         gfx.setColor(config.to_red, config.to_green, config.to_blue)
      elseif i >= settings.from_red then
         gfx.setColor(config.from_red, config.from_green, config.from_blue)
      else
         gfx.setColor(255,255,255)
      end
      gfx.print(setting.name,  x      , y)
      gfx.print(setting.value, x + 150, y)

      if hover then
         gfx.setColor(225,198,0)
         gfx.setFont(fontSmall)
         gfx.print('     +/- '..adjustRate, x + 170, y + math.floor((menuSpacing-fontSmall:getHeight())/2))
         gfx.setFont(fontNormal)
      end

      y = y + menuSpacing
   end
end

function settings:save()
   settings:write(configSelect:getSelected())
end

function settings:copy()
   local filename = os.date(filenameWriteTemplate)
   settings:write(filename)
   configSelect:add(filename)
end

function settings:delete()
   if #configSelect.items == 1 then
      status:show(3, 'Cannot delete last config.')
   else
      local filename = configSelect:getSelected()
      love.filesystem.remove(filename)
      table.remove(configSelect.items, configSelect.selected)
      configSelect:nextItem()
      status:show(3, '%s deleted.', filename)
   end
end

function settings:write(filename)
   local file = love.filesystem.newFile(filename)
   if file:open('w') then
      local configtext = writeTemplate:gsub('%%([%w_]+)', config)
      file:write(configtext)
      status:show(5, 'Config saved to: %s%s.', love.filesystem.getSaveDirectory(), filename)
  else
      status:show(5, 'Unable to open output file: %s%s', love.filesystem.getSaveDirectory(), filename)
  end
end

function settings:read()
   local configfile = configSelect:getSelected()
   local configtext = love.filesystem.read(configfile)
   local configdata = { coerce_to_number( configtext:match(readTemplate) ) }
   if #configdata < #settings then
      status:show(3, 'ERROR reading %s.', configfile )
   else
      local c = config
      c.x, c.y, c.x_offset, c.y_offset, c.buffer_size, c.emission_rate,
      c.lifetime, c.particle_life, c.from_red, c.from_green, c.from_blue,
      c.from_alpha, c.to_red, c.to_green, c.to_blue, c.to_alpha, c.size_min,
      c.size_max, c.size_variation, c.speed_min, c.speed_max, c.direction,
      c.spread, c.gravity_min, c.gravity_max, c.rotation_min, c.rotation_max,
      c.spin_min, c.spin_max, c.spin_variation, c.radial_acceleration,
      c.tangential_acceleration
      = unpack(configdata)
      status:show(3, '%s loaded.', configfile)
   end
end
