require('block_mgr')
require('board')
require('hexagon')
require('misc')
require('class')
require('log')

function test_board()
	board.init()
	board.print()
end

function test_hexagon()
	h = hexagon.create(1, 1)
	print(h.string())
end

function test_table_save()
	local t = {a=1,b=2,c=3}
	table.save(t, 'test_table_save')
	local t1 = table.load('test_table_save')
	for k,v in pairs(t1) do
		print(k,v)
	end
end

function gen_block_ids()
	local r = block_mgr.gen_ids_string()
	print(r)
end

function test_board_excel_string()
	local b = board.create()
	b.random_all(40)
	local str = b.excel_string()
	print(str)
end

function test_serialize()
	data = {["a"] = "a", ["b"] = "b", [1] = 1, [2] = 2, ["t"] = {1, 2, 3}}  
	local sz = serialize(data)	
end

function test_read_write_file()
	write_file('test', 'wahaha')
	local str = read_file('test')
	print(str)
end

function test_print()
	for i = 1, 100 do
		for j = 1, 10000000 do end
		io.write(i .. '\r')
		if i % 10 == 0 then
			print('10', i)
		end
	end
end

function test_board_k()
	local b = board.create()
	for k, r in pairs(b._kb_hex) do
		for b, hexs in pairs(r) do
			printf('k = %g b = %g', k, b)
		end
	end
end

function test_board_hex_kb()
	local b = board.create()
	b.foreach_hex(function (h)
		printf('%g %g:', h.rx, h.ry)
		
		for k, hexs in pairs(h.kb_hex) do
			local strs = {}
			for _, hex in ipairs(hexs) do
				table.insert(strs, string.format('(%g,%g)', hex.rx, hex.ry))
			end	
			printf('\tk[%g] = %s', k, table.concat(strs, ' '))
		end
	end)
end

function test_class()
	Foo = class(function (self, name)
		self.name = name
	end)

	function Foo:fun()
		print('Foo:fun()->' .. self.name)
	end

	function Foo:car()
		print('Foo:car()->' .. self.name)
	end

	Bar = class(Foo)

	function Bar:fun()
		Foo.fun(self)
	end

	b = Bar('bar')
	b:fun()
	b:car()

	f = Foo('foo')
	f:fun()
	f:car()
end

function test_math_ceil()
	for i = 1, 10 do
		print(i, math.ceil(i / 4))
	end
end

function test_log()
	set_log_level('fatal')
	debug('hello %s', 'world')
	info('hello %s', 'world')
	warning('hello %s', 'world')
	fatal('hello %s', 'world')
end
