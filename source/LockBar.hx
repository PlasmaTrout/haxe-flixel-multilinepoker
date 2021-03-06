package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil.LineStyle;
import flixel.ui.FlxBar;
using flixel.util.FlxSpriteUtil;


class LockBar extends FlxSprite {
	
	private var _lock:LockIcon;
	private var _level:Int;
	private var _xpFill:FlxBar;
	

	public function new(X:Float=0, Y:Float=0, level:Int){
		super(X,Y);
		loadGraphic("assets/images/emptylockbar.png");
		_level = level;
		setLockIcon(level);
		_xpFill = new FlxBar(this.x+15,this.y+12,FlxBarFillDirection.LEFT_TO_RIGHT,Std.int(this.width)-50,45,null,"",0,100,true);
		_xpFill.createFilledBar(FlxColor.TRANSPARENT,0x587F47DD,false);
	}

	public function showXpBarOverlay(){
		//trace("added");
		FlxG.state.add(_xpFill);
	}

	public override function destroy(){
		_lock.destroy();
		FlxG.state.remove(this);
	}

	public function removeXpBarOverlay(){
		FlxG.state.remove(_xpFill);
	}

	public function scaleOverlay(xpRange:Float, currentXp:Float){
		_xpFill.setRange(0,xpRange);
		_xpFill.value = currentXp;
	}

	public function setLockIcon(level:Int){
		this._lock = new LockIcon(0,0,this);
		_lock.drawLabel(_level);
	}

	public function centerScreen(){
		this.screenCenter();
		_lock.destroy();
		
		this._lock = new LockIcon(0,0,this);
		_lock.drawLabel(_level);
	}

}