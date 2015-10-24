function love.conf(t)
   t.modules.joystick = false
   t.modules.audio = false
   t.modules.keyboard = true
   t.modules.event = true
   t.modules.image = true
   t.modules.graphics = true
   t.modules.timer = true
   t.modules.mouse = true
   t.modules.sound = false
   t.modules.physics = false
--|    t.console = true
   t.title = "Particle Editor"
   t.author = "Eric Tetz"
   t.window.fullscreen = false
   t.window.vsync = false
   t.window.fsaa = 1
   t.window.width = 900
   t.window.height = 600
end
