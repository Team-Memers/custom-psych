package funkin.utility.gameplay;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class StrumNote extends FlxSprite
{
	private var dirArray:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var colorSwap:ColorSwap;
	public var resetAnim:Float = 0;
	private var noteData:Int = 0;
	public var direction:Float = 90;//plan on doing scroll directions soon -bb
	public var downScroll:Bool = false;//plan on doing scroll directions soon -bb
	public var sustainReduce:Bool = true;
	
	private var player:Int;
	
	public var texture(default, set):String = null;
	private function set_texture(value:String):String {
		if(texture != value) {
			texture = value;
			reloadNote();
		}
		return value;
	}

	public function new(x:Float, y:Float, leData:Int, player:Int) {
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		noteData = leData;
		this.player = player;
		this.noteData = leData;
		super(x, y);

		var skin:String = 'NOTE_assets';
		if(funkin.states.PlayState.SONG.arrowSkin != null && funkin.states.PlayState.SONG.arrowSkin.length > 1) skin = funkin.states.PlayState.SONG.arrowSkin;
		texture = skin; //Load texture and anims

		scrollFactor.set();
	}

	public function reloadNote()
	{
		var lastAnim:String = null;
		if(animation.curAnim != null) lastAnim = animation.curAnim.name;

		if(funkin.states.PlayState.isPixelStage)
		{
			loadGraphic(funkin.utility.Paths.image('pixelUI/' + texture));
			width = width / 4;
			height = height / 5;
			loadGraphic(funkin.utility.Paths.image('pixelUI/' + texture), true, Math.floor(width), Math.floor(height));

			antialiasing = false;
			setGraphicSize(Std.int(width * funkin.states.PlayState.daPixelZoom));

			animation.add('green', [6]);
			animation.add('red', [7]);
			animation.add('blue', [5]);
			animation.add('purple', [4]);
			
			var boob = noteData % 4;
			animation.add('static', [boob]);
			animation.add('pressed', [boob+4, boob+8], 12, false);
			animation.add('confirm', [boob+12, boob+16], 12, false);
		}
		else
		{
			frames = Paths.getSparrowAtlas(texture);
			animation.addByPrefix('green', 'arrowUP');
			animation.addByPrefix('blue', 'arrowDOWN');
			animation.addByPrefix('purple', 'arrowLEFT');
			animation.addByPrefix('red', 'arrowRIGHT');

			antialiasing = funkin.utility.Preferences.globalAntialiasing;
			setGraphicSize(Std.int(width * 0.7));

			var lowerCaseAnim:String = dirArray[noteData % 4].toLowerCase();
			animation.addByPrefix('static', 'arrow'+dirArray[noteData % 4]);
			animation.addByPrefix('pressed', lowerCaseAnim+' press', 24, false);
			animation.addByPrefix('confirm', lowerCaseAnim+' confirm', 24, false);
		}
		updateHitbox();

		if(lastAnim != null)
		{
			playAnim(lastAnim, true);
		}
	}

	public function postAddedToGroup() {
		playAnim('static');
		x += funkin.utility.gameplay.Note.swagWidth * noteData;
		x += 50;
		x += ((FlxG.width / 2) * player);
		ID = noteData;
	}

	override function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}
		//if(animation.curAnim != null){ //my bad i was upset
		if(animation.curAnim.name == 'confirm' && !funkin.states.PlayState.isPixelStage) {
			centerOrigin();
		//}
		}

		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		centerOffsets();
		centerOrigin();
		if(animation.curAnim == null || animation.curAnim.name == 'static') {
			colorSwap.hue = 0;
			colorSwap.saturation = 0;
			colorSwap.brightness = 0;
		} else {
			if (noteData > -1 && noteData < funkin.utility.Preferences.arrowHSV.length)
			{
				colorSwap.hue = funkin.utility.Preferences.arrowHSV[noteData][0] / 360;
				colorSwap.saturation = funkin.utility.Preferences.arrowHSV[noteData][1] / 100;
				colorSwap.brightness = funkin.utility.Preferences.arrowHSV[noteData][2] / 100;
			}

			if(animation.curAnim.name == 'confirm' && !funkin.states.PlayState.isPixelStage) {
				centerOrigin();
			}
		}
	}
}
