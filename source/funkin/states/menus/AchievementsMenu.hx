package funkin.states.menus;

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
import funkin.utility.Achievements;

using StringTools;

class AchievementsMenu extends funkin.utility.MusicBeatState
{
	#if ACHIEVEMENTS_ALLOWED
	var options:Array<String> = [];
	private var grpOptions:FlxTypedGroup<funkin.utility.Alphabet>;
	private static var curSelected:Int = 0;
	private var achievementArray:Array<AttachedAchievement> = [];
	private var achievementIndex:Array<Int> = [];
	private var descText:FlxText;

	override function create() {
		DiscordClient.changePresence("Achievements Menu", null);

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(funkin.utility.Paths.image('menuDesat'));
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.alpha = 0.6;
		menuBG.antialiasing = funkin.utility.Preferences.globalAntialiasing;
		add(menuBG);

		grpOptions = new FlxTypedGroup<funkin.utility.Alphabet>();
		add(grpOptions);

		funkin.utility.Achievements.loadAchievements();
		for (i in 0...funkin.utility.Achievements.achievementsStuff.length) {
			if(!funkin.utility.Achievements.achievementsStuff[i][3] || funkin.utility.Achievements.achievementsMap.exists(funkin.utility.Achievements.achievementsStuff[i][2])) {
				options.push(funkin.utility.Achievements.achievementsStuff[i]);
				achievementIndex.push(i);
			}
		}

		for (i in 0...options.length) {
			var achieveName:String = funkin.utility.Achievements.achievementsStuff[achievementIndex[i]][2];
			var optionText:funkin.utility.Alphabet = new Alphabet(280, 300, funkin.utility.Achievements.isAchievementUnlocked(achieveName) ? funkin.utility.Achievements.achievementsStuff[achievementIndex[i]][0] : '?', false);
			optionText.isMenuItem = true;
			optionText.targetY = i - curSelected;
			optionText.snapToPosition();
			grpOptions.add(optionText);

			var icon:funkin.utility.AttachedAchievement = new AttachedAchievement(optionText.x - 105, optionText.y, achieveName);
			icon.sprTracker = optionText;
			achievementArray.push(icon);
			add(icon);
		}

		descText = new FlxText(150, 600, 980, "", 32);
		descText.setFormat(funkin.utility.Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);
		changeSelection();

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			FlxG.sound.play(funkin.utility.Paths.sound('cancelMenu'));
			funkin.utility.MusicBeatState.switchState(new funkin.states.menus.MainMenu());
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
			}
		}

		for (i in 0...achievementArray.length) {
			achievementArray[i].alpha = 0.6;
			if(i == curSelected) {
				achievementArray[i].alpha = 1;
			}
		}
		descText.text = funkin.utility.Achievements.achievementsStuff[achievementIndex[curSelected]][1];
		FlxG.sound.play(funkin.utility.Paths.sound('scrollMenu'), 0.4);
	}
	#end
}
