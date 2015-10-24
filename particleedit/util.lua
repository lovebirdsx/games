-- return all arguments as numbers
function coerce_to_number(...)
   local args = {...}
   for k,v in pairs(args) do
      args[k] = tonumber(v)
   end
   return unpack(args)
end
