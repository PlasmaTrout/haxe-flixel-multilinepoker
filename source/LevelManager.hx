package;


import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flash.events.Event;
import flixel.FlxObject;
import flixel.tweens.FlxTween;
using flixel.util.FlxSpriteUtil;
import flixel.plugin.MouseEventManager;


class LevelManager {

	private static var _level:Int;
	private static var _currentXp:Int;
	private static var _levelRanges:Array<Int>;
	private static var _xpTable:Map<String,Int>;
	private var _levelText:FlxText;
	private var _currentXpText:FlxText;
	public static var _xpTowardsNextLevel:Int;
	private static var _xpTween:flixel.tweens.misc.NumTween;
	private static var _activeLockBar:LockBar;
	private var _lockbar5:LockBar;
	private var _lockbar10:LockBar;
	private var _lockbar20:LockBar;
	private var _lockbar30:LockBar;
	
	public function new(?level:Int=1){
		_level=level;
		
		_levelText = new FlxText(0,0,-1,"Level 1",32,true);
		_levelText.font = "IMPACT";

		_currentXpText = new FlxText(0,0,-1,"0xp",24,true);
		_currentXpText.font = "IMPACT";
		
		
		_currentXp = 0;
		_xpTowardsNextLevel = 0;
		
		_xpTable = [ "Pair"=>10, "TwoPair"=>20, "Triple"=>30,"Straight"=>40,"Flush"=>50,
		"StraightFlush"=>100,"RoyalFlush"=>200 ];
		_levelRanges = [0,25,45,70,100,130];

		initLockBars();
		

	}

	public function getLevel():Int{
		return _level;
	}

	public static function getXpRange():Int{
		return _levelRanges[_level+1]-_levelRanges[_level];
	}

	public function getCurrentXp():Int{
		return _xpTowardsNextLevel;
	}

	private static function levelUp():Void{
		_xpTowardsNextLevel = _currentXp-_levelRanges[_level];
		_level = _level+1;
		_activeLockBar.scaleOverlay(_levelRanges[_level]-_levelRanges[_level-1],_xpTowardsNextLevel);
	}

	public static function addXP(result:PokerResult):Void{
		var value = _xpTable[Std.string(result)];
		_currentXp = _currentXp+value;
		trace(Std.string(result)+"="+value);
		if(value != null){
			FlxTween.num(_xpTowardsNextLevel,_xpTowardsNextLevel+value,1,{ complete: xpAddCompleted, ease: FlxEase.quadInOut },function(x){
				_xpTowardsNextLevel = Std.int(x);
				_activeLockBar.scaleOverlay(getXpRange(),x);
			});

			
		}
	}

	private static function xpAddCompleted(tween:FlxTween){
		checkLevelUp(_currentXp,_level);
	}

	private static function checkLevelUp(_currentXp:Int,_level:Int){

		trace(_currentXp+">="+_levelRanges[_level]+" with "+_xpTowardsNextLevel);

		if(_currentXp >= _levelRanges[_level]){
			levelUp();
			checkLevelUp( _currentXp,_level+1);
		}
	}

	private function placeLevelText(){

		_levelText.x = _lockbar5.x+20;

		if(_level < 5){
			_levelText.y = _lockbar5.y+12;
			_currentXpText.y = _lockbar5.y+18;
		}

		_currentXpText.x = (_lockbar5.x+_lockbar5.width)-(_currentXpText.width+20);

	}

	private function initLockBars():Void{
    	_lockbar10 = new LockBar((FlxG.stage.stageWidth/2)-275,Constants.ROW_POSITIONS[2]+25,10);
    	FlxG.state.add(_lockbar10);

    	_lockbar5 = new LockBar(_lockbar10.x,Constants.ROW_POSITIONS[1]+25,5);
    	FlxG.state.add(_lockbar5);

    	_lockbar20 = new LockBar(_lockbar10.x,Constants.ROW_POSITIONS[3]+25,20);
    	FlxG.state.add(_lockbar20);

    	_lockbar30 = new LockBar(_lockbar20.x,Constants.ROW_POSITIONS[4]+25,30);
    	FlxG.state.add(_lockbar30);

    	if(_level < 5){
    		_lockbar5.showXpBarOverlay();
    		_activeLockBar = _lockbar5;


    	}

    	_activeLockBar.scaleOverlay(getXpRange(),_xpTowardsNextLevel);

    	FlxG.state.add(_levelText);
    	FlxG.state.add(_currentXpText);

    	placeLevelText();
    }

	public function update(){
		_currentXpText.text = Std.string(_xpTowardsNextLevel)+"xp";
		_levelText.text = "Level "+Std.string(_level);
	}


}