import 'helperfunctions'

---@enum TMJLayerTypes
TMJLayerTypes = {
	tilelayer = 'tilelayer',
	objectgroup = 'objectgroup'
}

---@class ChickenTiledLoader
---@field root TMJRoot
---@field tileset TSJTileset
---@field tilesetImageTable playdate.graphics.imagetable?
---@field tileMapsByLayer table<string, playdate.graphics.tilemap>
---@field loadTMJ fun(self: ChickenTiledLoader, path: string)
---@field getTileMapForLayer fun(self: ChickenTiledLoader, layerName: string): playdate.graphics.tilemap
---@field getObjectsForLayer fun(self: ChickenTiledLoader, layerName: string): TMJObject[]
---@field getLayerByName fun(self: ChickenTiledLoader, layerName: string): TMJLayer
---@field getPropsObj fun(self: ChickenTiledLoader, obj: TMJObject): table<string, string|integer|number|boolean>
---@field getPropsTile fun(self: ChickenTiledLoader, gid: integer): table<string, string|integer|number|boolean>
---@field getGidAtLayerPos fun(self: ChickenTiledLoader, x: integer, y: integer, layer: TMJLayer): integer

class('ChickenTiledLoader').extends()

---@param self ChickenTiledLoader
function ChickenTiledLoader:init()
	self.tileMapsByLayer = {}
end

---@param self ChickenTiledLoader
---@param layerName string
---@return TMJObject[]
function ChickenTiledLoader:getObjectsForLayer(layerName)
	---@type TMJLayer
	local res = arrFindFirst(self.root.layers, function(l)
		return l.name == layerName
	end)

	if res ~= nil then
		return res.objects
	end

	return {}
end

---@param self ChickenTiledLoader
---@param obj TMJObject
---@return table<string, string|integer|number|boolean>
function ChickenTiledLoader:getPropsObj(obj)
	local ret = {}

	for i = 1, #obj.properties do
		ret[obj.properties[i].name] = obj.properties[i].value
	end

	return ret
end

---@param self ChickenTiledLoader
---@param gid integer
---@return table<string, string|integer|number|boolean>
function ChickenTiledLoader:getPropsTile(gid)
	local tile = arrFindFirst(self.tileset.tiles, function(f) return f.id == gid end)

	if tile ~= nil then
		local ret = {}

		for i = 1, #tile.properties do
			ret[tile.properties[i].name] = tile.properties[i].value
		end

		return ret
	end

	return {}
end

---@param self ChickenTiledLoader
---@param name string
---@return TMJLayer
function ChickenTiledLoader:getLayerByName(name)
	return arrFindFirst(self.root.layers, function(f) return f.name == name end)
end

---@param self ChickenTiledLoader
---@param x number
---@param y number
---@param layer TMJLayer
---@return integer
function ChickenTiledLoader:getGidAtLayerPos(x, y, layer)
	return layer.data[(y - 1) * layer.width + x] - 1
end

---@param self ChickenTiledLoader
---@param layerName string
---@return playdate.graphics.tilemap
function ChickenTiledLoader:getTileMapForLayer(layerName)
	return self.tileMapsByLayer[layerName]
end

---@param self ChickenTiledLoader
---@param path string
function ChickenTiledLoader:loadTMJ(path)
	self.root = json.decodeFile(path)

	local folderPath = path:sub(1, strLastIndexOf(path, '/'))

	if self.root.tilesets[1].source ~= nil then
		self.tileset = json.decodeFile(folderPath .. self.root.tilesets[1].source)
	else
		self.tileset = self.root.tilesets[1] --[[@as TSJTileset]]
	end

	local tilesetImageName = folderPath .. self.tileset.image

	tilesetImageName = tilesetImageName:sub(1, strFirstIndexOf(tilesetImageName, '-table-') - 1)

	self.tilesetImageTable = playdate.graphics.imagetable.new(tilesetImageName)

	---@type TMJLayer[]
	local tileLayers = arrFilter(self.root.layers, function(l)
		return l.type == TMJLayerTypes.tilelayer
	end)

	for i = 1, #tileLayers do
		local layer = tileLayers[i]

		local tilemap = playdate.graphics.tilemap.new()
		tilemap:setImageTable(self.tilesetImageTable)

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
