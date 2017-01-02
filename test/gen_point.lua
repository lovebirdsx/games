local M = {}

local p1 = {x = 100, y = 50}
local p2 = {x = 400, y = 60}
local p3 = {x = 500, y = 400}
local p4 = {x = 50, y = 300}
local quad = {p1, p2, p3, p4}
local points = {}

function create_pos(x, y)
	return {x = x, y = y}
end

function random(...)
	return math.random(...)
end

-- 计算两点之间的距离
function distance(p1, p2)
    return ((p2.y - p1.y) ^ 2 + (p2.x - p1.x) ^ 2) ^ 0.5
end

-- 计算三角形的面积, p0, p1, p2是三角形的三个顶点坐标
function cal_triangle_area(p0, p1, p2)
    local a = distance(p0, p1)
    local b = distance(p1, p2)
    local c = distance(p2, p0)

    local s = (a + b + c) / 2
    return (s * (s - a) * (s - b) * (s - c)) ^ 0.5
end

-- 在三角形内随机生成一个点, p0, p1, p2是三角形的三个顶点坐标
function gen_point_trangle(p0, p1, p2)
    local r1 = random()
    local r2 = random()
    if r1 + r2 > 1 then
        r1 = 1 - r1
        r2 = 1 - r2
    end

    local x = p0.x + r1 * (p1.x - p0.x) + r2 * (p2.x - p0.x)
    local y = p0.y + r1 * (p1.y - p0.y) + r2 * (p2.y - p0.y)
    return create_pos(x, y)
end

-- 在四边形内随机生成一个点
-- p1, p2, p3, p4是四边形的四个顶点的坐标
function gen_point_quad(p1, p2, p3, p4)
    local ta1 = cal_triangle_area(p1, p2, p3)
    local ta2 = cal_triangle_area(p3, p4, p1)
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

function M.keypressed(key)
	if key == ' ' then
		for i = 1, 100 do
			gen_point()
		end
	end
end

function draw_line(p1, p2)
	love.graphics.line(p1.x, p1.y, p2.x, p2.y)
end

function M.draw()
	draw_line(p1, p2)
	draw_line(p2, p3)
	draw_line(p3, p4)
	draw_line(p4, p1)

	for i, p in ipairs(points) do
		love.graphics.circle('fill', p.x, p.y, 2)
	end
end

return M