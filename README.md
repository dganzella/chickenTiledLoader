# Chicken Tiled Loader
Load Tiled maps in playdate ( https://www.mapeditor.org/ )

![image](https://github.com/dganzella/chickenTiledLoader/assets/30127664/49d0fb01-8ce9-4b7f-a598-5b4840685300)


## installation

copy the following sources to your project 
source/ChickenTiledLoader.lua
source/helperfunctions.lua
source/Models

## example

in main.lua, you can check an example of loading a TMJ file

Run the project by opening it in vscode in windows and running Build and Run (Simulator).ps1

You always load it like thi

local tmjloader = ChickenTiledLoader()
tmjloader:loadTMJ('assets/example.tmj')

and then use the methods available in the tmjloader object itself.

To release, either let it run out of scope, or set it to nil

tmjloader = nil

## limitations

Can only load TMJ files (Tiled map JSON format), no TMX
Only supports a single TSJ tileset per TMJ. Either embedded in the TMJ itsekf or as a sepatate, referenced TSJ
Only supports orthogonal maps
The name of the images referenced in the TMJ files need to follow playdate's pattern, aka. image-table-width-height.png

## documentation

The project supports playdate type annotations: https://github.com/Minalien/playdate-type-annotations

These are all the methods.

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
