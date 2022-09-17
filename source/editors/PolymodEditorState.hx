package editors;

import polymod.ModList;
import polymod.PolymodHandler;
import polymod.PolymodEditorStateOption;
import flixel.group.FlxGroup;
import flixel.system.FlxSound;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;
import lime.utils.Assets;

class PolymodEditorState extends MusicBeatState
{
	#if MODS_ALLOWED
	var curSelected:Int = 0;

	var page:FlxTypedGroup<PolymodEditorStateOption> = new FlxTypedGroup<PolymodEditorStateOption>();

	public static var instance:PolymodEditorState;

	public static var enabledMods = [];

	public static var coolId:String;
	public static var disableButton:FlxButton;
	public static var enableButton:FlxButton;

	var bgtwo:FlxSprite;
	var bg:FlxSprite;

	var infoText:FlxText;
	var infoTextcool:FlxText;

	override function create()
	{
		var menuBG:FlxSprite;

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		bg.screenCenter();

		infoText = new FlxText(0, 0, 0, "NO MODS INSTALLED!", 12);
		infoText.scrollFactor.set();
		infoText.setFormat("VCR OSD Mono", 35, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoText.borderSize = 2;
		infoText.screenCenter();
		infoText.visible = false;
		infoText.antialiasing = true;
		add(infoText);

		infoTextcool = new FlxText(340, 340, Std.int(FlxG.width * 0.9), "", 12);
		infoTextcool.scrollFactor.set();
		infoTextcool.setFormat(Paths.font("vcr.ttf"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoTextcool.borderSize = 2;
		infoTextcool.screenCenter(Y);

		super.create();

		PolymodHandler.loadModMetadata();

		add(page);

		loadMods();
		FlxG.mouse.visible = true;
	}

	function loadMods()
	{
		page.forEachExists(function(option:PolymodEditorStateOption)
		{
			page.remove(option);
			option.kill();
			option.destroy();
		});

		var optionLoopNum:Int = 0;

		for (modId in PolymodHandler.metadataArrays)
		{
			var modOption = new PolymodEditorStateOption(ModList.modMetadatas.get(modId).title, modId, optionLoopNum);
			page.add(modOption);
			optionLoopNum++;
			coolId = modId;
		}

		if (optionLoopNum > 0)
		{
			buildUI();
		}

		infoText.visible = (page.length == 0);
	}

	function buildUI()
	{
		bg = new FlxSprite(0, 0).loadGraphic(Paths.image("menuDesat"));
		// bg.screenCenter(Y);

		bgtwo = new FlxSprite(720, 0).loadGraphic(Paths.image("menuDesat"));
		bgtwo.screenCenter(Y);

		PolymodEditorState.enableButton = new FlxButton(bg.x + 1120, 309, "Enable Mod", function()
		{
			page.members[curSelected].Mod_Enabled = true;
			if (!enabledMods.contains(page.members[curSelected].Option_Value))
			{
				enabledMods.push(page.members[curSelected].Option_Value);
			}
			ModList.setModEnabled(page.members[curSelected].Option_Value, page.members[curSelected].Mod_Enabled);
		});

		PolymodEditorState.disableButton = new FlxButton(bg.x + 1120, 380, "Disable Mod", function()
		{
			page.members[curSelected].Mod_Enabled = false;
			if (enabledMods.contains(page.members[curSelected].Option_Value))
			{
				enabledMods.remove(page.members[curSelected].Option_Value);
			}
			ModList.setModEnabled(page.members[curSelected].Option_Value, page.members[curSelected].Mod_Enabled);
		});

		enableButton.setGraphicSize(150, 70);
		enableButton.updateHitbox();
		enableButton.color = FlxColor.GREEN;
		enableButton.label.setFormat(Paths.font("pixel.otf"), 12, FlxColor.WHITE);
		enableButton.label.fieldWidth = 135;
		setLabelOffset(enableButton, 5, 22);

		disableButton.setGraphicSize(150, 70);
		disableButton.updateHitbox();
		disableButton.color = FlxColor.RED;
		disableButton.label.setFormat(Paths.font("pixel.otf"), 12, FlxColor.WHITE);
		disableButton.label.fieldWidth = 135;
		setLabelOffset(disableButton, 5, 22);

		add(bgtwo);
		add(infoTextcool);
		add(disableButton);
		add(enableButton);
	}

	override function update(elapsed:Float)
	{
		// a bit ugly but i was in a hurry
		if (page.length > 0)
		{
			infoTextcool.text = ModList.modMetadatas.get(PolymodHandler.metadataArrays[curSelected]).description;
			infoTextcool.visible = true;
			infoTextcool.antialiasing = true;
		}

		if (page.length > 0)
		{
			if (controls.UI_UP_P)
			{
				curSelected--;
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			}

			if (controls.UI_DOWN_P)
			{
				curSelected++;
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			}
		}

		if (controls.BACK)
		{
			PolymodHandler.loadMods();
			FlxG.mouse.visible = false;
			LoadingState.loadAndSwitchState(new MasterEditorState());
		}

		if (curSelected < 0)
			curSelected = page.length - 1;

		if (curSelected >= page.length)
			curSelected = 0;

		var bruh = 0;

		for (x in page.members)
		{
			x.Alphabet_Text.targetY = bruh - curSelected;
			bruh++;
		}
	}

	// haxeflixel bro why
	function setLabelOffset(button:FlxButton, x:Float, y:Float)
	{
		for (point in button.labelOffsets)
		{
			point.set(x, y);
		}
	}
	#end
}