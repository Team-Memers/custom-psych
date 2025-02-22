package funkin.states.options;

import funkin.utility.Discord.DiscordClient;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import funkin.utility.Controls;
import funkin.utility.Paths;

class OptionsMenu extends MusicBeatState
{
	var options:Array<String> = ['Note Colors', 'Controls', 'Adjust Offset and Combo Placement', 'Graphics', 'Visuals and UI', 'Gameplay'];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Note Colors':
				openSubState(new funkin.states.options.NoteCustomizer());
			case 'Controls':
				openSubState(new funkin.states.options.ControlsMenu());
			case 'Graphics':
				openSubState(new funkin.states.options.GraphicsSettingsMenu());
			case 'Visuals and UI':
				openSubState(new funkin.states.options.VisualsUIMenu());
			case 'Gameplay':
				openSubState(new funkin.states.options.GameplaySettingsMenu());
			case 'Adjust Offset and Combo Placement':
				Loading.loadAndSwitchState(new funkin.states.options.NoteOffsetMenu());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	override function create() {
		DiscordClient.changePresence("Options Menu", null);
		FlxG.stage.application.window.title = 'FNF: Psych Engine - Options Menu';

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		//bg.color = 0xFFea71fd;
		bg.alpha = 0.6;
		bg.updateHitbox();

		bg.screenCenter();
		bg.antialiasing = Preferences.globalAntialiasing;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		Preferences.saveSettings();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if(FlxG.mouse.wheel != 0)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
			changeSelection(-FlxG.mouse.wheel);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new funkin.states.menus.MainMenu());
		}

		if (controls.ACCEPT) {
			openSelectedSubstate(options[curSelected]);
		}
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}