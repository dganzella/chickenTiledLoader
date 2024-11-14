--CoreLibs
import 'CoreLibs/graphics'
import 'CoreLibs/object'
import 'CoreLibs/sprites'

import 'ChickenTMJLoader'

gfx = playdate.graphics
geo = playdate.geometry

playdate.display.setRefreshRate(30)
gfx.sprite.setAlwaysRedraw(true)

---tmj loading
local tmjloader = ChickenTMJLoader()
tmjloader:loadTMJ('assets/example.tmj')

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

---@type TMJLayer
local floor = tmjloader:getLayerByName('floor')

local mapXTiles = tmjloader.root.width
local mapYTiles = tmjloader.root.height
local tileWidth = tmjloader.root.tilewidth
local tileHeight = tmjloader.root.tileheight


local tileGidsThatAreNotGrounds = {}

for i = 1, mapXTiles do
	for j = 1, mapYTiles do
		local inmappos = geo.vector2D.new(i * tileWidth - tileWidth, j * tileHeight - tileHeight)

		local gid = tmjloader:getGidAtLayerPos(i, j, floor)
		if gid ~= nil and gid > 0 then
			local properties = tmjloader:getPropsTile(gid)

			print(gid, properties.solid)

			if not (properties.solid == true) then
				if not arrContains(tileGidsThatAreNotGrounds, gid + 1) then
					table.insert(tileGidsThatAreNotGrounds, gid + 1)
				end
			end
		end
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

			local table = gfx.imagetable.new('assets/example')

			local char = gfx.sprite.new(table:getImage(4))

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
