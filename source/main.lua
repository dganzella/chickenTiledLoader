--CoreLibs
import 'CoreLibs/graphics'
import 'CoreLibs/object'
import 'CoreLibs/sprites'

import 'pdtiledTMJLoader'

gfx = playdate.graphics
geo = playdate.geometry

---@param arr any[]
---@return boolean
local function arrContains(arr, val)
	for _, value in ipairs(arr) do
		if value == val then
			return true
		end
	end

	return false
end

playdate.display.setRefreshRate(30)
gfx.sprite.setAlwaysRedraw(true)

---tmj loading
local tmjloader = pdtiledTMJLoader.new()
tmjloader:loadTMJ('assets/example.tmj', TMJOpenMode.normal)

---creating sprites for tile layers

for name, tilemap in pairs(tmjloader.tileMapsByLayer) do
	local z = 0

	if name == 'bg' then
		z = 1
	elseif name == 'floor' then
		z = 2
	end

	local layerSprite = gfx.sprite.new()
	layerSprite:setTilemap(tilemap)
	layerSprite:moveTo(0, 0)
	layerSprite:setCenter(0, 0)
	layerSprite:setZIndex(z)
	layerSprite:add()
end

---creating collision for floor

local tileGidsThatAreGrounds = {}

for i = 1, #tmjloader.tileset.tiles do
	local tile = tmjloader.tileset.tiles[i]

	local properties = tmjloader:getPropsOfTile(tile)

	if properties.solid == true then
		if not arrContains(tileGidsThatAreGrounds, tile.id + 1) then
			table.insert(tileGidsThatAreGrounds, tile.id + 1)
		end
	end
end

local tileGidsThatAreNotGrounds = {}

for i = 1, tmjloader.tileset.tilecount do
	if not arrContains(tileGidsThatAreGrounds, i) then
		table.insert(tileGidsThatAreNotGrounds, i)
	end
end

playdate.graphics.sprite.addWallSprites(tmjloader.tileMapsByLayer['floor'], tileGidsThatAreNotGrounds)

---creating character

---@type TMJObject[]
local mainobjs = tmjloader:getObjectsForLayer('mainobjects')

if mainobjs ~= nil then
	for i = 1, #mainobjs do
		local obj = mainobjs[i]

		local rotation = obj.rotation

		local rad = math.rad(rotation)
		local sin = math.sin(rad)
		local cos = math.cos(rad)

		local inmappos = geo.vector2D.new(obj.x, obj.y) +
			geo.vector2D.new((sin + cos) * obj.width / 2, (sin - cos) * obj.height / 2)

		local properties = tmjloader:getPropsObj(obj)

		if obj.name == 'Char' then
			print('create char here, speed: ' .. tostring(properties.speed))

			local char = gfx.sprite.new(tmjloader:getTileImageByGid(obj.gid))

			char:moveTo(inmappos.x, inmappos.y)
			char:setZIndex(5)

			char:add()
		end
	end
end

---@diagnostic disable-next-line: duplicate-set-field
function playdate.update()
	gfx.sprite.update()
end
