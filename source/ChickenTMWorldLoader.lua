---@class ChickenTMWorldLoader
---@field maps table<string, ChickenTMJLoader>
---@field mapdefs table<string, TMJMap>
---@field world TMWorld
---@field loadTMWorld fun(self: ChickenTMWorldLoader, path: string)

ChickenTMWorldLoader = {}
---@return ChickenTMWorldLoader
function ChickenTMWorldLoader.new() return {} end

class('ChickenTMWorldLoader').extends()
ChickenTMWorldLoader.new = ChickenTMWorldLoader

---@param self ChickenTMWorldLoader
function ChickenTMWorldLoader:init()
	self.maps = {}
	self.mapdefs = {}
end

---@param self ChickenTMWorldLoader
---@param path string
function ChickenTMWorldLoader:loadTMWorld(path)
	self.world = json.decodeFile(path)

	for i = 1, #self.world.maps do
		local map = self.world.maps[i]

		local singleMap = ChickenTMJLoader.new()
		singleMap:loadTMJ(getPath(path) .. map.fileName)

		local mapName = strReplace(map.fileName, '.tmj', '')

		self.maps[mapName] = singleMap
		self.mapdefs[mapName] = map
	end
end
