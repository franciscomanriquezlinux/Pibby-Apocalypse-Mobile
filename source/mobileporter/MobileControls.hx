package mobileporter;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxSave;
import haxe.Json;
import openfl.Assets;

typedef ButtonLayout =
{
	id:String,
	key:String,
	shape:String,
	xPercent:Float,
	yPercent:Float,
	size:Int
}

typedef ControlsLayout =
{
	buttons:Array<ButtonLayout>,
	opacityIdle:Float,
	opacityPressed:Float,
	vibrateOnPress:Bool,
	vibrateDurationMs:Int
}

class MobileControls extends FlxGroup
{
	public var buttons:Map<String, TouchButton> = new Map();
	public var editMode:Bool = false;

	var save:FlxSave;

	public function new(layoutPath:String = "assets/data/controls_layout.json")
	{
		super();

		save = new FlxSave();
		save.bind("mobileporter_controls");

		var layout = loadLayout(layoutPath);
		buildButtons(layout);
	}

	function loadLayout(layoutPath:String):ControlsLayout
	{
		var raw = Assets.getText(layoutPath);
		return Json.parse(raw);
	}

	function buildButtons(layout:ControlsLayout):Void
	{
		var screenW = FlxG.width;
		var screenH = FlxG.height;

		for (buttonData in layout.buttons)
		{
			var posX = screenW * buttonData.xPercent;
			var posY = screenH * buttonData.yPercent;

			if (save.data.positions != null && Reflect.hasField(save.data.positions, buttonData.id))
			{
				var savedPos = Reflect.field(save.data.positions, buttonData.id);
				posX = savedPos.x;
				posY = savedPos.y;
			}

			var button = new TouchButton(
				posX, posY, buttonData.size, buttonData.id,
				layout.opacityIdle, layout.opacityPressed,
				layout.vibrateOnPress, layout.vibrateDurationMs
			);

			buttons.set(buttonData.id, button);
			add(button);
		}
	}

	public function isPressed(buttonID:String):Bool
	{
		var button = buttons.get(buttonID);
		return button != null && button.pressed;
	}

	public function isJustPressed(buttonID:String):Bool
	{
		var button = buttons.get(buttonID);
		return button != null && button.justPressed;
	}

	public function isJustReleased(buttonID:String):Bool
	{
		var button = buttons.get(buttonID);
		return button != null && button.justReleased;
	}

	public function setEditMode(enabled:Bool):Void
	{
		editMode = enabled;
		for (button in buttons)
			button.editable = enabled;
	}

	public function saveLayout():Void
	{
		var positions:Dynamic = {};
		for (id in buttons.keys())
		{
			var button = buttons.get(id);
			Reflect.setField(positions, id, {x: button.x, y: button.y});
		}
		save.data.positions = positions;
		save.flush();
	}

	public function resetLayout():Void
	{
		save.data.positions = null;
		save.flush();
	}

	public function show():Void
	{
		for (button in buttons)
			button.visible = true;
	}

	public function hide():Void
	{
		for (button in buttons)
			button.visible = false;
	}
}
