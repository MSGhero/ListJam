package;

import haxe.Json;
import hxd.res.Image;
import h2d.Tile;
import haxe.ds.StringMap;

@:forward(get, exists)
abstract Spritesheet(StringMap<Tile>) {
	
	public function new() {
		this = new StringMap();
	}
	
	public function loadTexturePackerData(sheet:Image, jsonString:String) {
		
		var sheetTile = sheet.toTile();
		var tpData:TexturePackerData = Json.parse(jsonString);
		
		this.set("__default", sheetTile); // add the whole sheet rect to the spritesheet, for ref
		
		for (tpt in tpData.frames) {
			this.set(tpt.filename, sheetTile.sub(tpt.frame.x, tpt.frame.y, tpt.frame.w, tpt.frame.h, tpt.spriteSourceSize.x, tpt.spriteSourceSize.y));
		}
		
		return this;
	}
	
	public function map(names:Array<String>):Array<Tile> {
		return names.map(this.get);
	}
	
	public function dispose() {
		
		for (tile in this) {
			tile.dispose();
		}
		
		this.clear();
	}
}