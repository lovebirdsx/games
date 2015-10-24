filenameWriteTemplate = '%y.%m.%d-%H.%M.%S.lua'
filenameMatchTemplate = '%d+%.%d+%.%d+%-%d+%.%d+%.%d+%.lua'

-- write template (provides a couple code options to copy and paste)
-- if you change this, you must change readTemplate and settings:load
writeTemplate =  [[
   -- hard coded
   system = love.graphics.newParticleSystem( yourSpriteHere, %emission_rate )
   system:setPosition( %x, %y )
   system:setOffset( %x_offset, %y_offset )
   system:setBufferSize( %buffer_size )
   system:setEmissionRate( %emission_rate )
   system:setLifetime( %lifetime )
   system:setParticleLife( %particle_life )
   system:setColor( %from_red, %from_green, %from_blue, %from_alpha, %to_red, %to_green, %to_blue, %to_alpha )
   system:setSize( %size_min, %size_max, %size_variation )
   system:setSpeed( %speed_min, %speed_max  )
   system:setDirection( math.rad(%direction) )
   system:setSpread( math.rad(%spread) )
   system:setGravity( %gravity_min, %gravity_max )
   system:setRotation( math.rad(%rotation_min), math.rad(%rotation_max) )
   system:setSpin( math.rad(%spin_min), math.rad(%spin_max), %spin_variation )
   system:setRadialAcceleration( %radial_acceleration )
   system:setTangentialAcceleration( %tangential_acceleration )

   -- via table
   system = {
      position = { %x, %y },
      offset = { %x_offset, %y_offset },
      bufferSize = %buffer_size,
      emissionRate = %emission_rate,
      lifetime = %lifetime,
      particleLife = %particle_life,
      color = { %from_red, %from_green, %from_blue, %from_alpha, %to_red, %to_green, %to_blue, %to_alpha },
      size = { %size_min, %size_max, %size_variation },
      speed = { %speed_min, %speed_max },
      direction = math.rad(%direction),
      spread = math.rad(%spread),
      gravity = { %gravity_min, %gravity_max },
      rotation = { math.rad(%rotation_min), math.rad(%rotation_max) },
      spin = { math.rad(%spin_min), math.rad(%spin_max), %spin_variation },
      radialAcceleration = %radial_acceleration,
      tangentialAcceleration = %tangential_acceleration,
   }
   system = love.graphics.newParticleSystem( yourSpriteHere, system.emissionRate )
   system:setPosition( unpack(system.position)
   system:setOffset( unpack(system.position) )
   system:setBufferSize( system.bufferSize )
   system:setEmissionRate( system.emissionRate )
   system:setLifetime( system.lifetime )
   system:setParticleLife( system.particleLife )
   system:setColor( unpack(system.color) )
   system:setSize( unpack(system.size) )
   system:setSpeed( unpack(system.speed) )
   system:setDirection( math.rad(system.direction) )
   system:setSpread( math.rad(system.spread) )
   system:setGravity( unpack(system.gravity)
   system:setRotation( unpack(system.rotation) )
   system:setSpin( unpack(system.spin) )
   system:setRadialAcceleration( system.radialAcceleration )
   system:setTangentialAcceleration( system.tangentialAcceleration )
]]

-- read template, for parsing our own output 
-- if you change this, you must change writeTemplate and settings:load
readTemplate = [[
   system = love.graphics.newParticleSystem%( yourSpriteHere, %-*[%d.]+ %)
   system:setPosition%( (%-*[%d.]+), (%-*[%d.]+) %)
   system:setOffset%( (%-*[%d.]+), (%-*[%d.]+) %)
   system:setBufferSize%( (%-*[%d.]+) %)
   system:setEmissionRate%( (%-*[%d.]+) %)
   system:setLifetime%( (%-*[%d.]+) %)
   system:setParticleLife%( (%-*[%d.]+) %)
   system:setColor%( (%-*[%d.]+), (%-*[%d.]+), (%-*[%d.]+), (%-*[%d.]+), (%-*[%d.]+), (%-*[%d.]+), (%-*[%d.]+), (%-*[%d.]+) %)
   system:setSize%( (%-*[%d.]+), (%-*[%d.]+), (%-*[%d.]+) %)
   system:setSpeed%( (%-*[%d.]+), (%-*[%d.]+)  %)
   system:setDirection%( math.rad%((%-*[%d.]+)%) %)
   system:setSpread%( math.rad%((%-*[%d.]+)%) %)
   system:setGravity%( (%-*[%d.]+), (%-*[%d.]+) %)
   system:setRotation%( math.rad%((%-*[%d.]+)%), math.rad%((%-*[%d.]+)%) %)
   system:setSpin%( math.rad%((%-*[%d.]+)%), math.rad%((%-*[%d.]+)%), (%-*[%d.]+) %)
   system:setRadialAcceleration%( (%-*[%d.]+) %)
   system:setTangentialAcceleration%( (%-*[%d.]+) %)
]]
