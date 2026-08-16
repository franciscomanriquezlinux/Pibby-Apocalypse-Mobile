package mobileporter;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import lime.system.System;

class TouchButton extends FlxSprite
{
	public var buttonID:String;
	public var pressed:Bool = false;
	public var justPressed:Bool = false;
	public var justReleased:Bool = false;
	public var editable:Bool = false;

	var wasPressed:Bool = false;
	var activeTouchID:Int = -1;
	var opacityIdle:Float;
	var opacityPressed:Float;
	var vibrateOnPress:Bool;
	var vibrateDurationMs:Int;
	var dragOffsetX:Float = 0;
	var dragOffsetY:Float = 0;

	public function new(x:Float, y:Float, size:Int, buttonID:String, opacityIdle:Float, opacityPressed:Float,
		vibrateOnPress:Bool, vibrateDurationMs:Int, ?graphicPath:String)
	{
		super(x, y);
		this.buttonID = buttonID;
		this.opacityIdle = opacityIdle;
		this.opacityPressed = opacityPressed;
		this.vibrateOnPress = vibrateOnPress;
		this.vibrateDurationMs = vibrateDurationMs;

		if (graphicPath != null)
			loadGraphic(graphicPath);
		else
			makeGraphic(size, size, 0x88FFFFFF);

		scrollFactor.set();
		alpha = opacityIdle;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (editable)
		{
			updateDrag();
			return;
		}

		updateTouchState();
	}

	function containsTouch(touch:flixel.input.touch.FlxTouch):Bool
	{
		return touch.x >= x && touch.x <= x + width && touch.y >= y && touch.y <= y + height;
	}

	function updateTouchState():Void
	{
		pressed = false;

		for (touch in FlxG.touches.list)
		{
			if (containsTouch(touch))
			{
				pressed = true;
				activeTouchID = touch.touchPointID;
				break;
			}
		}

		justPressed = pressed && !wasPressed;
		justReleased = !pressed && wasPressed;

		if (justPressed && vibrateOnPress)
			vibrate();

		wasPressed = pressed;

		alpha = pressed ? opacityPressed : opacityIdle;
	}

	function updateDrag():Void
	{
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed && containsTouch(touch))
			{
				activeTouchID = touch.touchPointID;
				dragOffsetX = x - touch.x;
				dragOffsetY = y - touch.y;
			}

			if (touch.touchPointID == activeTouchID && touch.pressed)
			{
				x = touch.x + dragOffsetX;
				y = touch.y + dragOffsetY;
			}

			if (touch.touchPointID == activeTouchID && touch.justReleased)
				activeTouchID = -1;
		}
	}

	function vibrate():Void
	{
		#if android
		System.vibrate(vibrateDurationMs / 1000);
		#end
	}

	public function fadeTo(targetAlpha:Float, duration:Float = 0.3):Void
	{
		FlxTween.tween(this, {alpha: targetAlpha}, duration);
	}
}
