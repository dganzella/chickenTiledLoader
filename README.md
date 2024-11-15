# Chicken Tiled Loader
Load Tiled maps in playdate ( https://www.mapeditor.org/ )

![image](https://github.com/dganzella/chickenTiledLoader/assets/30127664/4c71ca16-abd9-410b-9f04-4c87b9eed6e1)
![image](https://github.com/dganzella/chickenTiledLoader/assets/30127664/8dbf0a28-20ac-43b4-b99f-7c1d426d5180)


## installation

copy the following sources to your project:

- source/ChickenTMJLoader.lua
- source/helperfunctions.lua
- source/Models/*.lua (optional, for autocomplete)

## basic usage
```
import 'ChickenTMJLoader'

local tmjloader = ChickenTMJLoader()
tmjloader:loadTMJ('assets/example.tmj')
```
and then use the methods available in the tmjloader object itself, down in the documentation

To release, either let it run out of scope, or set it to nil if retaining a reference

```
tmjloader = nil
```

## example

in main.lua, you can check an example of loading a TMJ file

Run the project by opening it in vscode in windows and running Build and Run (Simulator).ps1

## world loading

The library now supports world loading

```
    self.tmxWorldLoader = ChickenTMWorld()
    self.tmxWorldLoader:loadTMWorld('example.world')
```

The world contains a table of TMJMap to ChickenTMJLoader in its map field maps

## limitations

- Can only load TMJ files (Tiled map JSON format), no TMX
- Only supports a single TSJ tileset per TMJ. Either embedded in the TMJ itself or as a sepatate, referenced TSJ. Multiple TMJ files can reference the same TSJ tileset, no problem.
- Only supports orthogonal maps
- The name of the images referenced in the TMJ/TSJ files need to follow playdate's pattern, aka. image-table-width-height.png

## documentation

The project supports playdate type annotations: https://github.com/Minalien/playdate-type-annotations

```
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
```

```
---@class ChickenTMWorld
---@field maps table<TMJMap, ChickenTMJLoader>
---@field world TMWorld
---@field loadTMWorld fun(self: ChickenTMWorld, path: string)
```