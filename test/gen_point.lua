local m = {}

local p1 = {100, 50}
local p2 = {400, 60}
local p3 = {500, 400}
local p4 = {50, 300}
local quad = {p1, p2, p3, p4}
local points = {}

function distance(p1, p2)
	return ((p1[1] - p2[1]) ^ 2 + (p1[2] - p2[2]) ^ 2) ^ 0.5
end

function gen_point_trangle(p0, p1, p2)
	local r1 = math.random()
	local r2 = math.random()
	if r1 + r2 > 1 then
		r1 = 1 - r1
		r2 = 1 - r2
	end

	local x = p0[1] + r1 * (p1[1] - p0[1]) + r2 * (p2[1] - p0[1])
	local y = p0[2] + r1 * (p1[2] - p0[2]) + r2 * (p2[2] - p0[2])
	return {x, y}
end

function cal_trangle_area(p0, p1, p2)
	local a = distance(p0, p1)
	local b = distance(p1, p2)
	local c = distance(p2, p0)

	local s = (a + b + c) / 2
	return (s * (s - a) * (s - b) * (s - c)) ^ 0.5
end

function gen_point_quad(p1, p2, p3, p4)
	local ta1 = cal_trangle_area(p1, p2, p3)
	local ta2 = cal_trangle_area(p3, p4, p1)
	local r = math.random()
	if r < ta1 / (ta1 + ta2) then
		return gen_point_trangle(p1, p2, p3)
	else
		return gen_point_trangle(p3, p4, p1)
	end
end

function gen_point()
	local p = gen_point_quad(p1, p2, p3, p4)
	points[#points + 1] = p
end

function m.keypressed(key)
	if key == ' ' then
		for i = 1, 100 do
			gen_point()
		end
	end
end

function draw_line(p1, p2)
	love.graphics.line(p1[1], p1[2], p2[1], p2[2])
end

function m.draw()
	draw_line(p1, p2)
	draw_line(p2, p3)
	draw_line(p3, p4)
	draw_line(p4, p1)

	for i, p in ipairs(points) do
		love.graphics.circle('fill', p[1], p[2], 2)
	end
end

return m