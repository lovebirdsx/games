require('block_mgr')
require('board')
require('hexagon')
require('misc')
require('class')
require('chapters')
require('log')
require('leader_board')
require('leader_board_cl')

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

function test_class2()
	Foo = class(function (self, name)
		self.name = name
	end)

	function Foo:fun()
		print(self.name)
	end

	Bar = class(Foo)

	Car = class(Foo, function (self)
		Foo.init(self, 'car')
	end)

	local b = Bar('bar')
	b:fun()

	local c = Car()
	c:fun()
end

function test_path()
	local path = 'stages/adjflasdjfajks.dat'
	local dir, file, ext = string.match(path, "(.-)([^\\/]-%.?([^%.\\/]*))$")
	print(dir, file, ext)
end

function test_list_files()
	local files = list_filepath('chapters')
	for i,v in ipairs(files) do
		print(i,v)
	end
end

function test_list_dirs()
	local files = list_dirs('chapters')
	for i,v in ipairs(files) do
		print(i,v)
	end
end

function test_chapters()
	chapters = Chapters('chapters')	
	for _, chapter in ipairs(chapters.chapters) do
		print(chapter.name)
		for _, stage in ipairs(chapter.stages) do
			print(stage.name)
			stage:load()
			print(stage.board.excel_string())
		end
	end
end

function test_gsub()
	local from = 'stages/hello_world.stage'
	print(from:gsub('/', '-'))
end

function test_copy_file()
	write_file('backup/a', 'wahaha')
	copy_file('backup/a', 'backup/b')
end

function test_get_file_attr()
	local attrs = lfs.attributes('backup/.DS_Store')
	for k,v in pairs(attrs) do
		print(k,v)
	end
end

function test_leader_board()
	os.remove('lb.save')

	lb = LeaderBoard('lb.save')	
	lb:set_max_record(4)	
	lb:add('a', 100)
	lb:add('b', 200)
	lb:add('c', 300)
	lb:add('d', 400)
	lb:add('e', 500)
	lb:output()

	lb2 = LeaderBoard('lb.save')
	lb2:load()
	lb2:output()
	lb2:add('a', 1000)
	lb2:add('b', 2000)

	lb3 = LeaderBoard('lb.save')
	lb3:output()
end

function test_leader_board_cl()
	local cl = LeaderBoardClient('localhost', 8888)
	cl:add('lovebird', 9999)
	local r = cl:get_all()
	for i,v in ipairs(r) do
		print(i, v.player, v.score)
	end
end

function test_leader_board_cl2()
	cl = LeaderBoard('lb.save')	
	cl:add('lovebird', 9999)
	local r = cl:get_all()
	for i,v in ipairs(r) do
		print(i, v.player, v.score)
	end
end

function test()
	test_leader_board_cl()
end
