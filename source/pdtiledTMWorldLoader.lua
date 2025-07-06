-- Helper Functions

---@param str string
---@param sep string?
local function getPath(str, sep)
	sep = sep or '/'
	return str:match('(.*' .. sep .. ')')
end

---@param inputstr string
---@param target string
---@param replacement string
---@return string
local function strReplace(inputstr, target, replacement)
	local str, _ = string.gsub(inputstr, target, replacement)
	return str
end

---@class pdtiledTMWorldLoader
---@field maps table<string, ChickenTMJLoader>
---@field mapdefs table<string, TMJMap>
---@field world TMWorld
---@field loadTMWorld fun(self: pdtiledTMWorldLoader, path: string)

pdtiledTMWorldLoader = {}
---@return pdtiledTMWorldLoader
function pdtiledTMWorldLoader.new() return {} end

class('pdtiledTMWorldLoader').extends()
pdtiledTMWorldLoader.new = pdtiledTMWorldLoader

---@param self pdtiledTMWorldLoader
function pdtiledTMWorldLoader:init()
	self.maps = {}
	self.mapdefs = {}
end

---@param self pdtiledTMWorldLoader
---@param path string
function pdtiledTMWorldLoader:loadTMWorld(path)
	self.world = json.decodeFile(path)

	for i = 1, #self.world.maps do
		local map = self.world.maps[i]

		local singleMap = ChickenTMJLoader.new()
		singleMap:loadTMJ(getPath(path) .. map.fileName, TMJOpenMode.normal)

		local mapName = strReplace(map.fileName, '.tmj', '')

		self.maps[mapName] = singleMap
		self.mapdefs[mapName] = map
	end
end
