# Chicken Tiled Loader
Load Tiled maps in playdate ( https://www.mapeditor.org/ )

![image](https://github.com/dganzella/chickenTiledLoader/assets/30127664/4c71ca16-abd9-410b-9f04-4c87b9eed6e1)
![image](https://github.com/user-attachments/assets/2f45008e-ecdb-4308-9517-b6feafe0e5c2)


## installation

copy the following sources to your project:

- source/ChickenTMJLoader.lua
- source/ChickenTMWorldLoader.lua
- source/helperfunctions.lua
- source/Models/*.lua (optional, for autocomplete)

## basic usage
```
import 'ChickenTMJLoader'

local tmjloader = ChickenTMJLoader.new()
tmjloader:loadTMJ('assets/example.tmj', TMJOpenMode.normal)
```
and then use the methods available in the tmjloader object itself, down in the documentation

## example

in main.lua, you can check an example of loading a TMJ file

Run the project by opening it in vscode in windows and running Build and Run (Simulator).ps1

## world loading

The library now supports world loading

```
    local tmxWorldLoader = ChickenTMWorldLoader.new()
    tmxWorldLoader:loadTMWorld('example.world')
    local tmjloader = tmxWorldLoader.maps['example']
```

The world contains a table of tmj map names to ChickenTMJLoader instances called ```maps```

## releasing data

To release most resources, let the variables run out of scope, and make sure not to keep any reference.

You can also use ```ChickenTMJLoader:releaseTilemaps()``` if you no longer need the tilemaps but still need other information.

To release resources completely, you need to call ```ChickenTMJLoader.releaseCachedImageTables()``` to release cached image tables. They are kept cached so they dont load multiple copies over and over again for multiple files that point to the same image tilesets

## using lua files for speed loading

Now ChickenTMJLoader supports the loading of lua files instead of TMJ/TSJ. All you have to do is export them using Tiled's "Export as" function to lua files with the same name as the original file, in the same folder, with the extension .lua instead of .tmj/tsj.

You can also use the settings "Repeat last export on save" option to always export to lua when the TMJ/TSJ file is saved, so you keep the lua file updated.

ps. It will always try to load the lua file first, if available.  
ps. The lua file will actually become a PDZ file in runtime.  

## open modes

Now ChickenTMJLoader supports two open modes. ```TMJOpenMode.normal``` and ```TMJOpenMode.loadRootOnly```.

The difference is that ```TMJOpenMode.loadRootOnly``` will only parse the tiled file and do nothing else. Wont create ```playdate.graphics.tilemap``` or load the referenced images.

This is useful for speed loading maps where you just need basic information, like the size of the map, position, or if it contaisn or not an object -- for example, when building in-game navigation maps.

## limitations

- Can only load TMJ files (Tiled map JSON format), no TMX
- Only supports a single TSJ tileset per TMJ. Either embedded in the TMJ itself or as a separate, referenced TSJ. Multiple TMJ files can reference the same TSJ tileset, no problem.
- Only supports orthogonal maps
- The name of the images referenced in the TMJ/TSJ files need to follow playdate's pattern, aka. image-table-width-height.png

## documentation

The project supports playdate type annotations: https://github.com/Minalien/playdate-type-annotations

```
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
```

```
---@class ChickenTMWorldLoader
---@field maps table<string, ChickenTMJLoader>
---@field mapdefs table<string, TMJMap>
---@field world TMWorld
---@field loadTMWorld fun(self: ChickenTMWorldLoader, path: string)
```
