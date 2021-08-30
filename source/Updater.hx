package;

// I need to put this class on github somewhere, it's so nice

@:structInit
class Updater {
	
	public var duration:Float;
	public var repetitions:Int = -1;
	public var callback:()->Void = () -> {};
	public var paused:Bool = false;
	public var useFrames:Bool = false;
	
	public var isActive(get, never):Bool;
	inline function get_isActive():Bool { return !paused && repetitions != 0; }
	
	var counter:Float = 0;
	
	public inline function dispose() {
		callback = null;
	}
	
	public inline function resetCounter() {
		counter = 0;
	}
	
	public inline function forceCallback() {
		callback();
		if (repetitions > 0) --repetitions;
		counter = 0;
	}
	
	public function forceFinish() {
		
		// only makes sense if there are repetitions
		while (repetitions-- > 0) {
			callback();
		}
	}
	
	public inline function stop() {
		repetitions = 0;
	}
	
	public function update(dt:Float) {
		
		if (isActive) {
			
			while (counter >= duration) {
			
				callback();
				
				if (repetitions > 0) --repetitions;
				counter -= duration;
			}
			
			if (!useFrames) counter += dt;
			else counter++;
		}
	}
}