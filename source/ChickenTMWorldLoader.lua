---@class ChickenTMWorld
---@field maps table<TMJMap, ChickenTMJLoader>
---@field world TMWorld
---@field loadTMWorld fun(self: ChickenTMWorld, path: string)

class('ChickenTMWorld').extends()

---@param self ChickenTMWorld
function ChickenTMWorld:init()
	self.maps = {}
end

---@param self ChickenTMWorld
---@param path string
function ChickenTMWorld:loadTMWorld(path)
	self.world = json.decodeFile(path)

	for i = 1, #self.world.maps do
		local map = self.world.maps[i]

		local singleMap = ChickenTMJLoader()
		singleMap:loadTMJ(map.fileName)
		self.maps[map] = singleMap
	end
end
