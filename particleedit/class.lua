-- Simple single-inheritence class mechanism
-- 
--    Foo = class()          -- subclass Object
--    function Foo:init(x,y) -- optional constructor
--        self.x, self.y = x, y
--    end
--    function Foo:report() 
--       print(self.x, self,y)
--    end
--    Bar = class(Foo)    -- subclass Foo
--    b = Bar:new('Eric') -- calls Foo:init
--    b:report()          -- Eric
--    
--    Zip = class(Bar)
--    function Zip:init(name, age)   -- override Foo constructor
--       self.super.init(self, name) -- call up the inheritence chain
--    end
--
--    z = Zip:new()
--    z:instance_of(Zip)  --> true
--    z:instance_of(Bar)  --> false
--    z:subclass_of(Bar)  --> true
--    z:subclass_of(Foo)  --> true

local Object -- base of the class heirarchy (forward reference)

function class(super)
   super = super or Object
   local prototype = setmetatable({}, super)
   prototype.super = super
   prototype.__index = prototype
   return prototype
end

Object = class()

-- default constructor provided so classes can always safely call super.init
function Object:init()
end

function Object:new(...)
   local instance = setmetatable({}, self)
   instance:init(...)
   return instance
end

function Object:instance_of(class)
   return getmetatable(self) == class
end

function Object:subclass_of(class)
   repeat
      self = getmetatable(self)
      if self == class then return true end
   until not self
   return false
end
