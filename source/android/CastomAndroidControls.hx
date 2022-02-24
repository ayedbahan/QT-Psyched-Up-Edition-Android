package android;

import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.math.FlxPoint;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import haxe.Json;
import android.Hitbox;
import android.AndroidControls.Config;
import android.FlxVirtualPad;

using StringTools;

class CastomAndroidControls extends MusicBeatState
{
	var _pad:FlxVirtualPad;
	var _hb:Hitbox;

	var upPozition:FlxText;
	var downPozition:FlxText;
	var leftPozition:FlxText;
	var rightPozition:FlxText;

	var inputvari:FlxText;

	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var controlitems:Array<String> = ['VIRTUALPAD_RIGHT','VIRTUALPAD_LEFT','VIRTUALPAD_CUSTOM','DUO','HITBOX','KEYBOARD'];

	var curSelected:Int = 0;

	var buttonistouched:Bool = false;

	var bindbutton:FlxButton;

	var config:Config;

	public static var menuBG:FlxSprite;

	override public function create():Void
	{
		super.create();
		
		config = new Config();
		curSelected = config.getcontrolmode();

		menuBG = new FlxSprite().loadGraphic(Paths.image('androidcontrols/menu/menuBG'));
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
                menuBG.color = 0xFFea71fd;
		menuBG.updateHitbox();
		menuBG.screenCenter();
		add(menuBG);

                var exitbutton = new FlxButton(FlxG.width - 200, 50, "Exit", function()
                {
			MusicBeatState.switchState(new options.OptionsState());
		});
		exitbutton.setGraphicSize(Std.int(exitbutton.width) * 3);
                exitbutton.label.setFormat(null, 16, 0x333333, "center");
		exitbutton.color = FlxColor.fromRGB(255,0,0);
		add(exitbutton);		

		var savebutton = new FlxButton(exitbutton.x, exitbutton.y + 100, "Save", function()
		{
			save();
			MusicBeatState.switchState(new options.OptionsState());
		});
		savebutton.setGraphicSize(Std.int(savebutton.width) * 3);
                savebutton.label.setFormat(null, 16, 0x333333, "center");
		savebutton.color = FlxColor.fromRGB(0,255,0);
		add(savebutton);

		_pad = new FlxVirtualPad(RIGHT_FULL, NONE);
		_pad.alpha = 0;
		add(_pad);

		_hb = new Hitbox();
		_hb.visible = false;
		add(_hb);

		inputvari = new FlxText(0, 50, 0, controlitems[curSelected], 48);
		inputvari.screenCenter(X);
		add(inputvari);

		var ui_tex = Paths.getSparrowAtlas('androidcontrols/menu/arrows');//thanks Andromeda Engine

		leftArrow = new FlxSprite(inputvari.x - 60,inputvari.y - 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		add(leftArrow);

		rightArrow = new FlxSprite(inputvari.x + inputvari.width + 10, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		add(rightArrow);

		upPozition = new FlxText(125, 200, 0,"Button Up X:" + _pad.buttonUp.x +" Y:" + _pad.buttonUp.y, 24);
		add(upPozition);

		downPozition = new FlxText(125, 250, 0,"Button Down X:" + _pad.buttonDown.x +" Y:" + _pad.buttonDown.y, 24);
		add(downPozition);

		leftPozition = new FlxText(125, 300, 0,"Button Left X:" + _pad.buttonLeft.x +" Y:" + _pad.buttonLeft.y, 24);
		add(leftPozition);

		rightPozition = new FlxText(125, 350, 0,"Button RIght x:" + _pad.buttonRight.x +" Y:" + _pad.buttonRight.y, 24);
		add(rightPozition);

		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		updatethefuckingpozitions();
		
		for (touch in FlxG.touches.list){		
			if(touch.overlaps(leftArrow) && touch.justPressed){
				changeSelection(-1);
			}else if (touch.overlaps(rightArrow) && touch.justPressed){
				changeSelection(1);
			}

			trackbutton(touch);
		}
	}

	function changeSelection(change:Int = 0)
	{
			curSelected += change;
	
			if (curSelected < 0)
				curSelected = controlitems.length - 1;
			if (curSelected >= controlitems.length)
				curSelected = 0;
	
			inputvari.text = controlitems[curSelected];

			var daChoice:String = controlitems[Math.floor(curSelected)];

			switch (daChoice)
			{
				case 'VIRTUALPAD_RIGHT':
					remove(_pad);
					_pad = null;
					_pad = new FlxVirtualPad(RIGHT_FULL, NONE);
					_pad.alpha = 0.75;
					add(_pad);
				case 'VIRTUALPAD_LEFT':
					remove(_pad);
					_pad = null;
					_pad = new FlxVirtualPad(FULL, NONE);
					_pad.alpha = 0.75;
					add(_pad);
				case 'VIRTUALPAD_CUSTOM':
					remove(_pad);
					_pad = null;
					_pad = new FlxVirtualPad(RIGHT_FULL, NONE);
					_pad.alpha = 0.75;
					add(_pad);
					loadcustom();
				case 'DUO':
					remove(_pad);
					_pad = null;
					_pad = new FlxVirtualPad(DUO, NONE);
					_pad.alpha = 0.75;
					add(_pad);
				case 'HITBOX':
					_pad.alpha = 0;                         
				case 'KEYBOARD':                     
					remove(_pad);
					_pad.alpha = 0;
			}

                        if (daChoice != "HITBOX")
			{
		                _hb.visible = false;
			}
                        else
                        {
				_hb.visible = true;
                        }

			if (daChoice != "VIRTUALPAD_CUSTOM")
			{
		                upPozition.visible = false;
				downPozition.visible = false;
				leftPozition.visible = false;
				rightPozition.visible = false;
			}
                        else
                        {
				upPozition.visible = true;
				downPozition.visible = true;
				leftPozition.visible = true;
				rightPozition.visible = true;
                        }
	}

	function trackbutton(touch:flixel.input.touch.FlxTouch){
		var daChoice:String = controlitems[Math.floor(curSelected)];

                if (daChoice == 'VIRTUALPAD_CUSTOM')
                {
			if (buttonistouched){
				
				if (bindbutton.justReleased && touch.justReleased)
				{
					bindbutton = null;
					buttonistouched = false;
				}else 
				{
					movebutton(touch, bindbutton);
					setbuttontexts();
				}

			}else {
				if (_pad.buttonUp.justPressed) {
					movebutton(touch, _pad.buttonUp);
				}
				
				if (_pad.buttonDown.justPressed) {
					movebutton(touch, _pad.buttonDown);
				}

				if (_pad.buttonRight.justPressed) {
					movebutton(touch, _pad.buttonRight);
				}

				if (_pad.buttonLeft.justPressed) {
					movebutton(touch, _pad.buttonLeft);
				}
			}
        }
	}

	function movebutton(touch:flixel.input.touch.FlxTouch, button:flixel.ui.FlxButton) {
		button.x = touch.x - _pad.buttonUp.width / 2;
		button.y = touch.y - _pad.buttonUp.height / 2;
		bindbutton = button;
		buttonistouched = true;
	}

	function setbuttontexts() {
		upPozition.text = "Button Up X:" + _pad.buttonUp.x +" Y:" + _pad.buttonUp.y;
		downPozition.text = "Button Down X:" + _pad.buttonDown.x +" Y:" + _pad.buttonDown.y;
		leftPozition.text = "Button Left X:" + _pad.buttonLeft.x +" Y:" + _pad.buttonLeft.y;
		rightPozition.text = "Button RIght x:" + _pad.buttonRight.x +" Y:" + _pad.buttonRight.y;
	}

	function save() {
		config.setcontrolmode(curSelected);
		var daChoice:String = controlitems[Math.floor(curSelected)];

    	        if (daChoice == 'VIRTUALPAD_CUSTOM'){
			savecustom();
		}
	}

	function savecustom() {
		config.savecustom(_pad);
	}

	function loadcustom():Void{
		_pad = config.loadcustom(_pad);	
	}

	function resizebuttons(vpad:FlxVirtualPad, ?int:Int = 200) {
		for (button in vpad){
				button.setGraphicSize(260);
				button.updateHitbox();
		}
	}

	function updatethefuckingpozitions() {
		leftArrow.x = inputvari.x - 60;
		rightArrow.x = inputvari.x + inputvari.width + 10;
		inputvari.screenCenter(X);
	}

	override function destroy()
	{
		super.destroy();
	}
}
