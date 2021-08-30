package;

import h2d.Object;
import h2d.Tile;
import h2d.col.Point;
import h2d.Anim;

class Monkey extends Object {
	
	public var vel:Point;
	public var acc:Point;
	public var maxVel:Float;
	public var alive:Bool;
	
	var anim:Anim;
	
	public function new(tile:Tile) {
		super();
		
		// set the regis point to the middle of the feet
		anim = new Anim([tile], 1, this);
		anim.x = -tile.width / 2;
		anim.y = -tile.height;
		
		vel = new Point();
		acc = new Point();
		
		alive = true;
	}
	
	public function update(dt:Float) {
		
		x += vel.x * dt;
		y += vel.y * dt;
		
		vel.x += acc.x * dt;
		vel.y += acc.y * dt;
	}
	
	public function kill() {
		
		alive = false;
		maxVel = 0;
		vel.x = 0;
		
		anim.color.setColor(0xffdd5555); // basic hit effect
	}
	
	public function revive() {
		
		alive = true;
		
		vel.x = Math.random() * 200 - 100;
		vel.y = Math.random() * -400 + 150;
		
		if (vel.x < 0) scaleX = 1;
		else scaleX = -1;
		
		maxVel = Math.random() * -250 - 200;
		
		anim.color.setColor(0xffffffff);
	}
}