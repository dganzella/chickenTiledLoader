-- GENERIC HELPER FUNCTIONS
---@param cond boolean
---@param T any
---@param F any
---@return any
local function tern(cond, T, F)
	if cond then return T else return F end
end

-- STRING HELPER FUNCTIONS

---@param inputstr string
---@param tofind string
---@return integer?
local function strFirstIndexOf(inputstr, tofind)
	return inputstr:find(tofind, 1, true)
end

---@param inputstr string
---@param target string
---@param replacement string
---@return string
local function strReplace(inputstr, target, replacement)
	local str, _ = string.gsub(inputstr, target, replacement)
	return str
end

--ARRAY HELPER FUNCTIONS

---@param arr any[]
---@param f function
---@return any[]
local function arrFilter(arr, f)
	local t = {}
	for i = 1, #arr do
		if f(arr[i]) then
			table.insert(t, arr[i])
		end
	end
	return t
end

---@param arr any[]
---@param f fun(a: any): boolean
---@return any?
local function arrFindFirst(arr, f)
	for i = 1, #arr do
		if f(arr[i]) then
			return arr[i]
		end
	end

	return nil
end

---@param arr any[]
---@param f fun(a: any): boolean
---@return boolean
local function arrSome(arr, f)
	for i = 1, #arr do
		if f(arr[i]) then
			return true
		end
	end

	return false
end

--path
---@param str string
---@param sep string?
local function getPath(str, sep)
	sep = sep or '/'
	return str:match('(.*' .. sep .. ')')
end

------------------ End of Helper Functions ------------------

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

---@class pdtiledTMJLoader
---@field isLuaPDZ boolean
---@field fullPath string
---@field root TMJRoot
---@field tileset TSJTileset
---@field finalImagePath string
---@field tileMapsByLayer table<string, playdate.graphics.tilemap>
---@field objectsById table<integer, TMJObject>
---@field tilePropertiesByGid table<integer, table<string,TMJPropertyType>>
---@field loadTMJ fun(self: pdtiledTMJLoader, fullPath: string, openMode: TMJOpenMode)
---@field mapIdToObjects fun(self: pdtiledTMJLoader)
---@field mapGidToProperties fun(self: pdtiledTMJLoader)
---@field getTileMapForLayer fun(self: pdtiledTMJLoader, layerName: string): playdate.graphics.tilemap
---@field getObjectsForLayer fun(self: pdtiledTMJLoader, layerName: string): TMJObject[]
---@field getLayerByName fun(self: pdtiledTMJLoader, layerName: string): TMJLayer
---@field getPropsObj fun(self: pdtiledTMJLoader, obj: TMJObject): table<string, TMJPropertyType>
---@field getPropsTileOfGid fun(self: pdtiledTMJLoader, gid: integer): table<string, TMJPropertyType>
---@field getPropsOfTile fun(self: pdtiledTMJLoader, tile: TSJTile): table<string, TMJPropertyType>
---@field getPropsOfMap fun(self: pdtiledTMJLoader): table<string, TMJPropertyType>
---@field getGidAtLayerPos fun(self: pdtiledTMJLoader, x: integer, y: integer, layer: TMJLayer): integer
---@field releaseTilemaps fun(self: pdtiledTMJLoader)
---@field layerHasAnyObjectWithType fun(self: pdtiledTMJLoader, layerName: string, type: string): boolean
---@field getFirstObjectWithType fun(self: pdtiledTMJLoader, layerName: string, type: string): TMJObject
---@field getTileImageByGid fun(self: pdtiledTMJLoader, gid: integer): playdate.graphics.image?
---@field getTileImageByGidGrid fun(self: pdtiledTMJLoader, initialGid: integer, width: integer, height: integer, tileSize: integer): playdate.graphics.image?
---@field buildProps fun(self: pdtiledTMJLoader, props: TProperty[] | table<string,TProperty>): table<string, TMJPropertyType>

pdtiledTMJLoader = {}
---@return pdtiledTMJLoader
function pdtiledTMJLoader.new() return {} end

class('pdtiledTMJLoader').extends()
pdtiledTMJLoader.new = pdtiledTMJLoader

---@type table<string, playdate.graphics.imagetable?>
pdtiledTMJLoader.cachedImageTables = {}

pdtiledTMJLoader.releaseCachedImageTables = function()
	pdtiledTMJLoader.cachedImageTables = {}
end

---@param self pdtiledTMJLoader
function pdtiledTMJLoader:init()
	self.tileMapsByLayer = {}
	self.objectsById = {}
	self.tilePropertiesByGid = {}
	self.finalImagePath = ''
	self.isLuaPDZ = false
end

---@param self pdtiledTMJLoader
function pdtiledTMJLoader:releaseTilemaps()
	self.tileMapsByLayer = {}
end

---@param self pdtiledTMJLoader
---@param gid integer
---@return playdate.graphics.image?
function pdtiledTMJLoader:getTileImageByGid(gid)
	return pdtiledTMJLoader.cachedImageTables[self.finalImagePath]:getImage(gid)
end

---@param initialGid integer
---@param width integer
---@param height integer
---@param tileSize integer
---@return playdate.graphics.image?
function pdtiledTMJLoader:getTileImageByGidGrid(initialGid, width, height, tileSize)
	local finalImage = playdate.graphics.image.new(width * tileSize, height * tileSize)

	local imagetable = pdtiledTMJLoader.cachedImageTables[self.finalImagePath]

	local widthImageTable, _ = imagetable:getSize()

	playdate.graphics.lockFocus(finalImage)
	for x = 0, width - 1 do
		for y = 0, height - 1 do
			imagetable:getImage(initialGid + (y * widthImageTable) + x):draw(x * tileSize,
				y * tileSize)
		end
	end
	playdate.graphics.unlockFocus()

	return finalImage
end

---@param self pdtiledTMJLoader
---@param layerName string
---@return TMJObject[]
function pdtiledTMJLoader:getObjectsForLayer(layerName)
	---@type TMJLayer
	local res = arrFindFirst(self.root.layers, function(l)
		return l.name == layerName
	end)

	if res ~= nil then
		return res.objects
	end

	return {}
end

---@param self pdtiledTMJLoader
---@param layerName string
---@param type string
---@return boolean
function pdtiledTMJLoader:layerHasAnyObjectWithType(layerName, type)
	local objs = self:getObjectsForLayer(layerName)

	return arrSome(objs,
		---@param obj TMJObject
		function(obj)
			return obj.type == type
		end)
end

---@param self pdtiledTMJLoader
---@param layerName string
---@param type string
---@return TMJObject
function pdtiledTMJLoader:getFirstObjectWithType(layerName, type)
	local objs = self:getObjectsForLayer(layerName)

	return arrFindFirst(objs,
		---@param obj TMJObject
		function(obj)
			return obj.type == type
		end)
end

---@package
---@param self pdtiledTMJLoader
---@param props TProperty[] | table<string,TProperty>
---@return table<string, TMJPropertyType>
function pdtiledTMJLoader:buildProps(props)
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

---@param self pdtiledTMJLoader
---@param obj TMJObject
---@return table<string, TMJPropertyType>
function pdtiledTMJLoader:getPropsObj(obj)
	return self:buildProps(obj.properties)
end

---@param self pdtiledTMJLoader
---@param gid integer
---@return table<string, TMJPropertyType>
function pdtiledTMJLoader:getPropsTileOfGid(gid)
	return self.tilePropertiesByGid[gid] or {}
end

---@param self pdtiledTMJLoader
---@param tile TSJTile
---@return table<string, TMJPropertyType>
function pdtiledTMJLoader:getPropsOfTile(tile)
	return self:buildProps(tile.properties)
end

---@param self pdtiledTMJLoader
---@return table<string, TMJPropertyType>
function pdtiledTMJLoader:getPropsOfMap()
	return self:buildProps(self.root.properties)
end

---@param self pdtiledTMJLoader
---@param name string
---@return TMJLayer
function pdtiledTMJLoader:getLayerByName(name)
	return arrFindFirst(self.root.layers, function(f) return f.name == name end)
end

---@param self pdtiledTMJLoader
---@param x number
---@param y number
---@param layer TMJLayer
---@return integer
function pdtiledTMJLoader:getGidAtLayerPos(x, y, layer)
	return layer.data[y * layer.width + x + 1] - 1
end

---@param self pdtiledTMJLoader
---@param layerName string
---@return playdate.graphics.tilemap
function pdtiledTMJLoader:getTileMapForLayer(layerName)
	return self.tileMapsByLayer[layerName]
end

---@package
---@param self pdtiledTMJLoader
function pdtiledTMJLoader:mapIdToObjects()
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
---@param self pdtiledTMJLoader
function pdtiledTMJLoader:mapGidToProperties()
	for i = 1, #self.tileset.tiles do
		local tile = self.tileset.tiles[i]
		self.tilePropertiesByGid[tile.id] = self:getPropsOfTile(tile)
	end
end

---@param self pdtiledTMJLoader
---@param fullPath string
---@param openMode TMJOpenMode
function pdtiledTMJLoader:loadTMJ(fullPath, openMode)
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

	if pdtiledTMJLoader.cachedImageTables[self.finalImagePath] == nil then
		local tilesetPathWithoutTable = self.finalImagePath:sub(1, strFirstIndexOf(self.finalImagePath, '-table-') - 1)

		pdtiledTMJLoader.cachedImageTables[self.finalImagePath] = playdate.graphics.imagetable.new(
			tilesetPathWithoutTable)
	end

	---@type TMJLayer[]
	local tileLayers = arrFilter(self.root.layers, function(l)
		return l.type == TMJLayerTypes.tilelayer
	end)

	for i = 1, #tileLayers do
		local layer = tileLayers[i]

		local tilemap = playdate.graphics.tilemap.new()
		tilemap:setImageTable(pdtiledTMJLoader.cachedImageTables[self.finalImagePath])

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
