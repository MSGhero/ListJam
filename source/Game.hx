package;

import h2d.Anim;
import hxd.res.Sound;
import io.newgrounds.NG;
import h2d.Bitmap;
import hxd.Res;
import haxe.ui.components.Button;
import haxe.ui.core.Component;
import hxd.Event;
import hxd.Window;
import hxd.Key;
import haxe.ui.components.Label;
import haxe.ui.macros.ComponentMacros;
import h2d.Object;

class Game extends Object {
	
	var dia:Label;
	var diaUpdate:Updater;
	var finalText:String;
	var options:Component;
	
	var leftPic:Bitmap;
	var rightPic:Bitmap;
	var leftSpeaking:Bool;
	var speech:Anim;
	
	var monkeys:Array<Monkey>;
	var sheet:Spritesheet;
	
	var alphaUpdater:Updater;
	var effectUpdater:Updater;
	var noAdvance:Bool;
	
	var GROUND:Float = 330;
	var LEFT:Float = 250;
	var RIGHT:Float = 1024 - 350;
	
	var currTrack:Sound;
	var hitSFXs:Array<Sound>;
	
	public function new(?parent) {
		super(parent);
		
		var bg = new Bitmap(Res.Background.toTile(), this);
		
		sheet = new Spritesheet();
		sheet.loadTexturePackerData(Res.monkeys_png, Res.monkeys_json.entry.getText());
		
		var inds = [1, 2, 3, 4, 5];
		var temp, r;
		// shuffle so you get a random character each time
		for (i in 0...5) {
			r = Std.random(5);
			temp = inds[i];
			inds[i] = inds[r];
			inds[r] = temp;
		}
		
		monkeys = [for (i in 0...5) new Monkey(sheet.get('Boy_000${inds[i]}_rs'))];
		
		for (monkey in monkeys) {
			
			monkey.x = Math.random() * (RIGHT - LEFT) + LEFT;
			monkey.y = GROUND;
			
			monkey.revive();
			
			addChild(monkey);
		}
		
		leftPic = new Bitmap(sheet.get('Boy_000${inds[0]}'), this);
		leftPic.x = 10; leftPic.y = 250;
		rightPic = new Bitmap(sheet.get('Girl_000${inds[Std.random(inds.length)]}'), this);
		rightPic.x = 714; rightPic.y = 250;
		
		speech = new Anim([Res.SpeechL.toTile(), Res.SpeechR.toTile()], 1, this);
		speech.x = 225; speech.y = 425;
		speech.pause = true;
		
		var root = ComponentMacros.buildComponent("assets/dia.xml");
		dia = root.findComponent("dia");
		options = root.findComponent("options");
		addChild(root);
		
		// temp until I figure out how to set the font size in haxeui-heaps (bug?)
		dia.getTextDisplay().sprite.smooth = true;
		dia.getTextDisplay().sprite.font.resizeTo(18);
		
		diaUpdate = { duration : 0.04, repetitions : 0, callback : () -> dia.text = finalText.substr(0, dia.text.length + 1) };
		resetDialogue();
		
		Window.getInstance().propagateKeyEvents = false;
		Window.getInstance().addEventTarget(onEvent);
		
		currTrack = Res.Jumpin_Monkeys;
		currTrack.play(true);
		hitSFXs = [Res.Monkey_Kill2, Res.Monkey_kill3, Res.Monkey_kill4];
		
		alphaUpdater = { duration : 1, repetitions : 150, useFrames : true, paused : true, callback : () -> rightPic.alpha -= 0.0067 };
		effectUpdater = { duration : 2, repetitions : 0 };
	}
	
	function onEvent(e:Event) {
		
		switch (e.kind) {
			case ERelease:
				forceText();
			case EKeyUp:
				if (e.keyCode == Key.SPACE) {
					if (options.hidden) forceText();
					else {
						resetOptions(); // pressing space will "select" one of the options randomly, I guess
					}
				}
			default:
		}
		
		// add gamepad support
	}
	
	public function update(dt:Float) {
		
		for (monkey in monkeys) {
			
			monkey.update(dt);
			
			if (monkey.y > GROUND) {
				// bed is a spring so monkeys can bounce around
				monkey.acc.y = (GROUND - monkey.y) * 200 + 800; // I think I'm injecting energy into the system here, but w/e this isn't physics class
			}
			
			else {
				// gravity, just set the value each time no one is looking
				monkey.acc.y = 800;
			}
			
			if (monkey.x < LEFT && monkey.vel.x < 0 || monkey.x > RIGHT && monkey.vel.x > 0) {
				monkey.vel.x *= -1; 
				monkey.scaleX *= -1;
			}
			
			monkey.vel.y = Math.max(monkey.vel.y, monkey.maxVel);
		}
		
		diaUpdate.update(dt);
		effectUpdater.update(dt);
		alphaUpdater.update(dt);
	}
	
	function forceText() {
		
		if (noAdvance) return;
		
		var forceNoOptions = false;
		
		if (!monkeys[0].alive) {
			// reset
			
			leftPic.color.setColor(0xffffffff);
			rightPic.color.setColor(0xffffffff);
			
			setSpeaker(true);
			
			for (monkey in monkeys) monkey.revive();
			
			forceNoOptions = true;
			
			currTrack.stop();
			currTrack = Res.Jumpin_Monkeys;
			currTrack.play(true);
			
			diaUpdate.paused = false;
			speech.visible = true;
			dia.show();
		}
		
		else if (!monkeys[4].alive) {
			// can't advance further, the end
			return;
		}
		
		if (!options.hidden) resetOptions(); // if options are already showing, just advance past
		
		if (diaUpdate.isActive) {
			diaUpdate.stop();
			dia.text = finalText;
		}	
		
		else {
			
			// random chance it goes to options instead
			var r = Math.random();
			
			if (r < 0.8 || forceNoOptions) {
				resetDialogue();
			}
			
			else {
				
				for (child in options.childComponents) {
					
					if (child is Button) {
						
						child.text = Dialogue.getWords(Std.random(2) + 1);
						
						// it's easier if the buttons don't actually do anything
						/*
						child.onClick = e -> {
							resetOptions();
						};
						*/
					}
				}
				
				if (!effectUpdater.isActive) options.show();
				// else, it creates options, but we just keep them hidden until the next call to this function
				// so it doesn't show options while dialogue is still typing out
			}
		}
	}
	
	function resetDialogue() {
		
		finalText = Dialogue.nextText();
		dia.text = "";
		diaUpdate.repetitions = finalText.length;
		
		setSpeaker(Math.random() < 0.5);
	}
	
	function resetOptions() {
		
		options.hide();
		resetDialogue();
		
		// delay by 1s to show effect
		noAdvance = true;
		diaUpdate.paused = true;
		effectUpdater.resetCounter();
		effectUpdater.repetitions = 1;
		effectUpdater.duration = 1;
		
		if (Math.random() < 0.3) { // 30% chance you lose each round
			effectUpdater.callback = playerDeath;
		}
		
		else {
			effectUpdater.callback = monkeyDeath;
		}
	}
	
	function playerDeath() {
		
		hitSFXs[Std.random(hitSFXs.length)].play();
		
		monkeys[0].kill();
		
		leftPic.alpha = 1;
		leftPic.color.setColor(0xffdd5555); // basic hit effect
		
		alphaUpdater.resetCounter();
		alphaUpdater.repetitions = 150;
		alphaUpdater.paused = false;
		
		effectUpdater.resetCounter();
		effectUpdater.repetitions = 2; // hack bc it gets reduced by one when the callback finishes. I should change that... later
		effectUpdater.duration = 0.75;
		effectUpdater.callback = () -> noAdvance = false;
		
		dia.hide();
		speech.visible = false;
		
		currTrack.stop();
	}
	
	function monkeyDeath() {
		
		hitSFXs[Std.random(hitSFXs.length)].play();
		
		var battle = false, end = false;
		for (i in 1...monkeys.length) {
				
			if (monkeys[i].alive) {
				
				monkeys[i].kill();
				
				if (i == 1) {
					battle = true;
				}
				
				else if (i == 4) {
					
					if (NG.core.loggedIn) {
						
						var medal = NG.core.medals.get(64979);
						
						if (!medal.unlocked) {
							medal.onUnlock.addOnce(() -> trace('${medal.name} unlocked'));
							medal.sendUnlock();
						}
					}
					
					dia.hide();
					speech.visible = false;
					end = true;
					
					// just stays here, no more gameplay
				}
				
				break;
			}
		}
		
		effectUpdater.resetCounter();
		effectUpdater.repetitions = 2; // hack bc it gets reduced by one when the callback finishes
		effectUpdater.duration = 0.75;
		
		if (battle) { 
				
			effectUpdater.callback = () -> {
				noAdvance = diaUpdate.paused = false;
				currTrack.stop();
				currTrack = Res.Mama_Called_the_Doctor;
				currTrack.play(true);
			}
			
			currTrack.stop(); // a bit more dramatic when the sound cuts off here
		}
		
		else if (end) {
			
			effectUpdater.callback = () -> {
				noAdvance = diaUpdate.paused = false;
				currTrack.stop();
				currTrack = Res.Monkey_Credits;
				currTrack.play(true);
				leftPic.alpha = rightPic.alpha = 1;
				rightPic.x = 200;
			}
			
			currTrack.stop();
		}
		
		else {
			effectUpdater.callback = () -> noAdvance = diaUpdate.paused = false;
		}
	}
	
	function setSpeaker(left:Bool) {
		
		if (left) {
			leftPic.alpha = 1;
			rightPic.alpha = 0.6;
			speech.currentFrame = 0;
			
		}
		
		else {
			leftPic.alpha = 0.6;
			rightPic.alpha = 1;
			speech.currentFrame = 1;
		}
	}
}