package;

import io.newgrounds.NG;
import haxe.ui.Toolkit;
import hxd.Res;
import hxd.App;

class Main extends App {
	
	var game:Game;
	
	static function main() {
		Res.initEmbed();
		new Main();
	}
	
	override function init() {
		
		var ngapi = Res.ngapi.entry.getText();
		var lines = ngapi.split("\r\n");
		
		NG.createAndCheckSession(StringTools.trim(lines[0]));
		NG.core.initEncryption(StringTools.trim(lines[1]));
		
		if (!NG.core.attemptingLogin) NG.core.requestLogin(onNGLogin);
		else NG.core.onLogin.add(onNGLogin);
		
		engine.backgroundColor = 0xffffffff;
		
		Toolkit.init({ root : s2d });
		
		game = new Game(s2d);
	}
	
	override function update(dt:Float) {
		super.update(dt);
		
		game.update(dt);
	}
	
	function onNGLogin():Void {
		
		trace('hi ${NG.core.user.name}');
		
		NG.core.requestMedals(() -> {
			trace('got medals');
		});
	}
}