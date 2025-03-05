import 'helperfunctions'

---@enum TMJLayerTypes
TMJLayerTypes = { ---@class TMJLayerTypes.*
	tilelayer = 'tilelayer',
	objectgroup = 'objectgroup'
}

---@enum TMJOpenMode
TMJOpenMode = { ---@class OpenMode.*
	normal = 'normal',
	loadRootOnly = 'loadRootOnly',
}

---@class ChickenTMJLoader
---@field isLuaPDZ boolean
---@field fullPath string
---@field root TMJRoot
---@field tileset TSJTileset
---@field finalImagePath string
---@field tileMapsByLayer table<string, playdate.graphics.tilemap>
---@field objectsById table<integer, TMJObject>
---@field tilePropertiesByGid table<integer, table<string,TMJPropertyType>>
---@field loadTMJ fun(self: ChickenTMJLoader, fullPath: string, openMode: TMJOpenMode)
---@field mapIdToObjects fun(self: ChickenTMJLoader)
---@field mapGidToProperties fun(self: ChickenTMJLoader)
---@field getTileMapForLayer fun(self: ChickenTMJLoader, layerName: string): playdate.graphics.tilemap
---@field getObjectsForLayer fun(self: ChickenTMJLoader, layerName: string): TMJObject[]
---@field getLayerByName fun(self: ChickenTMJLoader, layerName: string): TMJLayer
---@field getPropsObj fun(self: ChickenTMJLoader, obj: TMJObject): table<string, TMJPropertyType>
---@field getPropsTileOfGid fun(self: ChickenTMJLoader, gid: integer): table<string, TMJPropertyType>
---@field getPropsOfTile fun(self: ChickenTMJLoader, tile: TSJTile): table<string, TMJPropertyType>
---@field getPropsOfMap fun(self: ChickenTMJLoader): table<string, TMJPropertyType>
---@field getGidAtLayerPos fun(self: ChickenTMJLoader, x: integer, y: integer, layer: TMJLayer): integer
---@field releaseTilemaps fun(self: ChickenTMJLoader)
---@field layerHasAnyObjectWithType fun(self: ChickenTMJLoader, layerName: string, type: string): boolean
---@field getFirstObjectWithType fun(self: ChickenTMJLoader, layerName: string, type: string): TMJObject
---@field getTileImageByGid fun(self: ChickenTMJLoader, gid: integer): playdate.graphics.image?
---@field getTileImageByGidGrid fun(self: ChickenTMJLoader, initialGid: integer, width: integer, height: integer): playdate.graphics.image?
---@field buildProps fun(self: ChickenTMJLoader, props: TProperty[] | table<string,TProperty>): table<string, TMJPropertyType>

ChickenTMJLoader = {}
---@return ChickenTMJLoader
function ChickenTMJLoader.new() return {} end

class('ChickenTMJLoader').extends()
ChickenTMJLoader.new = ChickenTMJLoader

---@type table<string, playdate.graphics.imagetable?>
ChickenTMJLoader.cachedImageTables = {}

ChickenTMJLoader.releaseCachedImageTables = function()
	ChickenTMJLoader.cachedImageTables = {}
end

---@param self ChickenTMJLoader
function ChickenTMJLoader:init()
	self.tileMapsByLayer = {}
	self.objectsById = {}
	self.tilePropertiesByGid = {}
	self.finalImagePath = ''
	self.isLuaPDZ = false
end

---@param self ChickenTMJLoader
function ChickenTMJLoader:releaseTilemaps()
	self.tileMapsByLayer = {}
end

---@param self ChickenTMJLoader
---@param gid integer
---@return playdate.graphics.image?
function ChickenTMJLoader:getTileImageByGid(gid)
	return ChickenTMJLoader.cachedImageTables[self.finalImagePath]:getImage(gid)
end

---@param initialGid integer
---@param width integer
---@param height integer
---@return playdate.graphics.image?
function ChickenTMJLoader:getTileImageByGidGrid(initialGid, width, height)
	local finalImage = playdate.graphics.image.new(width * constants_base.tile_size, height * constants_base.tile_size)

	local imagetable = ChickenTMJLoader.cachedImageTables[self.finalImagePath]

	local widthImageTable, _ = imagetable:getSize()

	playdate.graphics.lockFocus(finalImage)
	for x = 0, width - 1 do
		for y = 0, height - 1 do
			imagetable:getImage(initialGid + (y * widthImageTable) + x):draw(x * constants_base.tile_size,
				y * constants_base.tile_size)
		end
	end
	playdate.graphics.unlockFocus()

	return finalImage
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
---@param layerName string
---@param type string
---@return boolean
function ChickenTMJLoader:layerHasAnyObjectWithType(layerName, type)
	local objs = self:getObjectsForLayer(layerName)

	return arrSome(objs,
		---@param obj TMJObject
		function(obj)
			return obj.type == type
		end)
end

---@param self ChickenTMJLoader
---@param layerName string
---@param type string
---@return TMJObject
function ChickenTMJLoader:getFirstObjectWithType(layerName, type)
	local objs = self:getObjectsForLayer(layerName)

	return arrFindFirst(objs,
		---@param obj TMJObject
		function(obj)
			return obj.type == type
		end)
end

---@package
---@param self ChickenTMJLoader
---@param props TProperty[] | table<string,TProperty>
---@return table<string, TMJPropertyType>
function ChickenTMJLoader:buildProps(props)
	local ret = {}

	if props ~= nil then
		if self.isLuaPDZ then
			for k, v in pairs(props or {}) do
				if type(v) == 'table' and v['id'] ~= nil then
					ret[k] = v['id']
				else
					ret[k] = v
				end
			end
		else
			for i = 1, #props do
				ret[props[i].name] = props[i].value
			end
		end
	end

	return ret
end

---@param self ChickenTMJLoader
---@param obj TMJObject
---@return table<string, TMJPropertyType>
function ChickenTMJLoader:getPropsObj(obj)
	return self:buildProps(obj.properties)
end

---@param self ChickenTMJLoader
---@param gid integer
---@return table<string, TMJPropertyType>
function ChickenTMJLoader:getPropsTileOfGid(gid)
	return self.tilePropertiesByGid[gid] or {}
end

---@param self ChickenTMJLoader
---@param tile TSJTile
---@return table<string, TMJPropertyType>
function ChickenTMJLoader:getPropsOfTile(tile)
	return self:buildProps(tile.properties)
end

---@param self ChickenTMJLoader
---@return table<string, TMJPropertyType>
function ChickenTMJLoader:getPropsOfMap()
	return self:buildProps(self.root.properties)
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
	return layer.data[y * layer.width + x + 1] - 1
end

---@param self ChickenTMJLoader
---@param layerName string
---@return playdate.graphics.tilemap
function ChickenTMJLoader:getTileMapForLayer(layerName)
	return self.tileMapsByLayer[layerName]
end

---@package
---@param self ChickenTMJLoader
function ChickenTMJLoader:mapIdToObjects()
	for i = 1, #self.root.layers do
		local layer = self.root.layers[i]

		if layer.type == TMJLayerTypes.objectgroup then
			for j = 1, #layer.objects do
				local object = layer.objects[j]
				self.objectsById[object.id] = object
			end
		end
	end
end

---@package
---@param self ChickenTMJLoader
function ChickenTMJLoader:mapGidToProperties()
	for i = 1, #self.tileset.tiles do
		local tile = self.tileset.tiles[i]
		self.tilePropertiesByGid[tile.id] = self:getPropsOfTile(tile)
	end
end

---@param self ChickenTMJLoader
---@param fullPath string
---@param openMode TMJOpenMode
function ChickenTMJLoader:loadTMJ(fullPath, openMode)
	self.fullPath = fullPath

	local cachePdzPath = strReplace(self.fullPath, '.tmj', '.pdz')

	self.isLuaPDZ = playdate.file.exists(cachePdzPath) --[[@as boolean]]

	if self.isLuaPDZ then
		self.root = playdate.file.run(cachePdzPath) --[[@as TMJRoot]]
	else
		self.root = json.decodeFile(self.fullPath)
	end

	if openMode == TMJOpenMode.loadRootOnly then
		return
	end

	self:mapIdToObjects()

	local folderPath = getPath(self.fullPath)

	local isReferencedTileset = (not self.isLuaPDZ and self.root.tilesets[1].source ~= nil) or (
		self.isLuaPDZ and self.root.tilesets[1].filename ~= nil)

	local referencedTilesetPath = tern(self.isLuaPDZ, self.root.tilesets[1].filename, self.root.tilesets[1].source)

	if isReferencedTileset then
		local finalPathTSJPath = folderPath .. referencedTilesetPath
		local tsjCachedPdzPath = strReplace(finalPathTSJPath, '.tsj', '.pdz')
		local tsjCachedExists = playdate.file.exists(tsjCachedPdzPath)

		if tsjCachedExists then
			self.tileset = playdate.file.run(tsjCachedPdzPath) --[[@as TSJTileset]]
		else
			self.tileset = json.decodeFile(finalPathTSJPath)
		end
	else
		self.tileset = self.root.tilesets[1] --[[@as TSJTileset]]
	end

	self:mapGidToProperties()

	if isReferencedTileset then
		self.finalImagePath = folderPath .. getPath(referencedTilesetPath) .. self.tileset.image
	else
		self.finalImagePath = folderPath .. self.tileset.image
	end

	if ChickenTMJLoader.cachedImageTables[self.finalImagePath] == nil then
		local tilesetPathWithoutTable = self.finalImagePath:sub(1, strFirstIndexOf(self.finalImagePath, '-table-') - 1)

		ChickenTMJLoader.cachedImageTables[self.finalImagePath] = playdate.graphics.imagetable.new(
			tilesetPathWithoutTable)
	end

	---@type TMJLayer[]
	local tileLayers = arrFilter(self.root.layers, function(l)
		return l.type == TMJLayerTypes.tilelayer
	end)

	for i = 1, #tileLayers do
		local layer = tileLayers[i]

		local tilemap = playdate.graphics.tilemap.new()
		tilemap:setImageTable(ChickenTMJLoader.cachedImageTables[self.finalImagePath])

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
