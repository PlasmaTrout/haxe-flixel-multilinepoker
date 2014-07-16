package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
using flixel.util.FlxSpriteUtil;


class LockBar extends FlxSprite {

	private var _lockIcon:FlxSprite;
	private var _lock:LockIcon;
	private var _level:Int;

	public function new(X:Float=0, Y:Float=0, level:Int){
		super(X,Y);
		loadGraphic("assets/images/emptylockbar.png");
		_level = level;
		setLockIcon(level);
		
		
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