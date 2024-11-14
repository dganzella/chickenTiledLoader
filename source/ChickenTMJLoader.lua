import 'helperfunctions'

---@enum TMJLayerTypes
TMJLayerTypes = { ---@class TMJLayerTypes.*
	tilelayer = 'tilelayer',
	objectgroup = 'objectgroup'
}

---@class ChickenTMJLoader
---@field root TMJRoot
---@field tileset TSJTileset
---@field tileMapsByLayer table<string, playdate.graphics.tilemap>
---@field loadTMJ fun(self: ChickenTMJLoader, path: string)
---@field getTileMapForLayer fun(self: ChickenTMJLoader, layerName: string): playdate.graphics.tilemap
---@field getObjectsForLayer fun(self: ChickenTMJLoader, layerName: string): TMJObject[]
---@field getLayerByName fun(self: ChickenTMJLoader, layerName: string): TMJLayer
---@field getPropsObj fun(self: ChickenTMJLoader, obj: TMJObject): table<string, string|integer|number|boolean>
---@field getPropsTileOfGid fun(self: ChickenTMJLoader, gid: integer): table<string, string|integer|number|boolean>
---@field getPropsOfTile fun(self: ChickenTMJLoader, tile: TSJTile): table<string, string|integer|number|boolean>
---@field getGidAtLayerPos fun(self: ChickenTMJLoader, x: integer, y: integer, layer: TMJLayer): integer
---@field releaseTilemaps fun(self: ChickenTMJLoader)

class('ChickenTMJLoader').extends()

---@type table<string, playdate.graphics.imagetable?>
ChickenTMJLoader.cachedImageTables = {}

ChickenTMJLoader.releaseCachedImageTables = function()
	ChickenTMJLoader.cachedImageTables = {}
end

---@param self ChickenTMJLoader
function ChickenTMJLoader:init()
	self.tileMapsByLayer = {}
end

---@param self ChickenTMJLoader
function ChickenTMJLoader:releaseTilemaps()
	self.tileMapsByLayer = {}
end

---@param self ChickenTMJLoader
---@param layerName string
---@return TMJObject[]
function ChickenTMJLoader:getObjectsForLayer(layerName)
	---@type TMJLayer
	local res = arrFindFirst(self.root.layers, function(l)
		return l.name == layerName
	end)

	if res ~= nil then
		return res.objects
	end

	return {}
end

---@param self ChickenTMJLoader
---@param obj TMJObject
---@return table<string, string|integer|number|boolean>
function ChickenTMJLoader:getPropsObj(obj)
	local ret = {}

	for i = 1, #obj.properties do
		ret[obj.properties[i].name] = obj.properties[i].value
	end

	return ret
end

---@param self ChickenTMJLoader
---@param gid integer
---@return table<string, string|integer|number|boolean>
function ChickenTMJLoader:getPropsTileOfGid(gid)
	local tile = arrFindFirst(self.tileset.tiles, function(f) return f.id == gid end)

	if tile ~= nil then
		return self:getPropsOfTile(tile)
	end

	return {}
end

---@param self ChickenTMJLoader
---@param tile TSJTile
---@return table<string, string|integer|number|boolean>
function ChickenTMJLoader:getPropsOfTile(tile)
	local ret = {}

	for i = 1, #tile.properties do
		ret[tile.properties[i].name] = tile.properties[i].value
	end

	return ret
end

---@param self ChickenTMJLoader
---@param name string
---@return TMJLayer
function ChickenTMJLoader:getLayerByName(name)
	return arrFindFirst(self.root.layers, function(f) return f.name == name end)
end

---@param self ChickenTMJLoader
---@param x number
---@param y number
---@param layer TMJLayer
---@return integer
function ChickenTMJLoader:getGidAtLayerPos(x, y, layer)
	return layer.data[(y - 1) * layer.width + x] - 1
end

---@param self ChickenTMJLoader
---@param layerName string
---@return playdate.graphics.tilemap
function ChickenTMJLoader:getTileMapForLayer(layerName)
	return self.tileMapsByLayer[layerName]
end

---@param self ChickenTMJLoader
---@param path string
function ChickenTMJLoader:loadTMJ(path)
	self.root = json.decodeFile(path)

	local folderPath = path:sub(1, strLastIndexOf(path, '/'))

	if self.root.tilesets[1].source ~= nil then
		self.tileset = json.decodeFile(folderPath .. self.root.tilesets[1].source)
	else
		self.tileset = self.root.tilesets[1] --[[@as TSJTileset]]
	end

	if ChickenTMJLoader.cachedImageTables[self.tileset.image] == nil then
		local tilesetImageName = folderPath .. self.tileset.image

		tilesetImageName = tilesetImageName:sub(1, strFirstIndexOf(tilesetImageName, '-table-') - 1)

		local tilesetImageTable = playdate.graphics.imagetable.new(tilesetImageName)

		ChickenTMJLoader.cachedImageTables[self.tileset.image] = tilesetImageTable
	end

	---@type TMJLayer[]
	local tileLayers = arrFilter(self.root.layers, function(l)
		return l.type == TMJLayerTypes.tilelayer
	end)

	for i = 1, #tileLayers do
		local layer = tileLayers[i]

		local tilemap = playdate.graphics.tilemap.new()
		tilemap:setImageTable(ChickenTMJLoader.cachedImageTables[self.tileset.image])

		tilemap:setSize(layer.width, layer.height)

		self.tileMapsByLayer[layer.name] = tilemap

		local x = 1
		local y = 1

		for j = 1, #layer.data do
			local tileIndex = layer.data[j]

			if tileIndex > 0 then
				tilemap:setTileAtPosition(x, y, tileIndex)
			end

			x += 1
			if x > layer.width then
				x = 1
				y += 1
			end
		end

		table[layer.name] = tilemap
	end
end
