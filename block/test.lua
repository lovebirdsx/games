require('block_mgr')
require('board')
require('hexagon')
require('table_save')
require('misc')

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

-- test_hexagon()
-- test_board()
-- test_table_save()
-- gen_block_ids()
-- math.randomseed(os.time())
-- test_board_excel_string()
-- test_serialize()
-- test_read_write_file()
-- printf('%02d', 1)
test_print()
