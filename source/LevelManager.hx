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
import flixel.util.FlxSignal;
import flixel.util.FlxSave;
using flixel.util.FlxSpriteUtil;
import flixel.plugin.MouseEventManager;


class LevelManager {

	private static var _level:Int;
	private static var _currentXp:Int;
	private static var _levelRanges:Array<Int>;
	private static var _xpTable:Map<String,Int>;
	private static var _levelText:FlxText;
	private static var _currentXpText:FlxText;
	public static var _xpTowardsNextLevel:Int;
	private static var _xpTween:flixel.tweens.misc.NumTween;
	private static var _activeLockBar:LockBar;
	private static var _lockbar5:LockBar;
	private static var _lockbar10:LockBar;
	private static var _lockbar20:LockBar;
	private static var _lockbar30:LockBar;
	public static var _levelSignal:FlxTypedSignal<Int->Void>;
	private static var _saveGame:FlxSave;
	
	public function new(){

		_saveGame = new FlxSave();
		_saveGame.bind("LatchDCrazyPoker");
		//trace(_saveGame.data);

		_levelRanges = [0,25,50,75,100,125,150,175,200,225,250,275,300,325,350,375,400,425,450,475,500,525,
		550,575,600,625,650,675,700,725,750,775,800,825,850,875,900];

		if(_saveGame.data.level != null){
			_level = _saveGame.data.level;
		}else{
			_level=1;
		}

		_levelSignal = new FlxTypedSignal<Int->Void>();
		// These set you xp to approximately what they would have been if you just
		// jumped in at a specific level. Not only were they needed for testing but
		// saving levels.

		if(_saveGame.data.xp != null){
			_currentXp = _saveGame.data.xp;
			_xpTowardsNextLevel = _saveGame.data.xpn;
		}else{
			_currentXp = _levelRanges[_level];
			_xpTowardsNextLevel = _currentXp - _levelRanges[_level];
		}
		
		_levelText = new FlxText(0,0,-1,"Level 1",32,true);
		_levelText.font = "IMPACT";

		_currentXpText = new FlxText(0,0,-1,"0xp",24,true);
		_currentXpText.font = "IMPACT";
		_currentXpText.alignment = "center";
		
		_xpTable = [ "Pair"=>10, "TwoPair"=>20, "Triple"=>30,"Straight"=>40,"Flush"=>50,
		"StraightFlush"=>100,"RoyalFlush"=>200 ];
		
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
		updateLockbars();
		_levelSignal.dispatch(_level);
		_saveGame.data.level = _level;
		
		_saveGame.flush();
	}

	public static function addXP(result:PokerResult):Void{
		var value = _xpTable[Std.string(result)];
		_currentXp = _currentXp+value;
		//trace(Std.string(result)+"="+value);
		if(value != null){
			FlxTween.num(_xpTowardsNextLevel,_xpTowardsNextLevel+value,1,{ complete: xpAddCompleted, ease: FlxEase.quadInOut },function(x){
				_xpTowardsNextLevel = Std.int(x);
				_activeLockBar.scaleOverlay(getXpRange(),x);
			});

			
		}

	
	}

	private static function xpAddCompleted(tween:FlxTween){
		//trace(_xpTowardsNextLevel);
		checkLevelUp(_currentXp,_level);
		_saveGame.data.xp = _currentXp; 
		_saveGame.data.xpn = _xpTowardsNextLevel;
		_saveGame.flush();
	}

	private static function checkLevelUp(_currentXp:Int,_level:Int){

		//trace(_currentXp+">="+_levelRanges[_level]+" with "+_xpTowardsNextLevel);

		if(_currentXp >= _levelRanges[_level]){
			levelUp();
			checkLevelUp( _currentXp,_level+1);
		}
	}

	private static function placeLevelText(){

		_levelText.x = _lockbar5.x+20;

		if(_level < 5){
			_levelText.y = _lockbar5.y+12;
			_currentXpText.y = _lockbar5.y+18;
		}else if((_level >= 5) &&  (_level < 10)){
			_levelText.y = _lockbar10.y+12;
			_currentXpText.y = _lockbar10.y+18;
			_lockbar5.destroy();
		}else if((_level >=10)&&(_level < 20)){
			_levelText.y = _lockbar20.y+12;
			_currentXpText.y = _lockbar20.y+18;
			_lockbar10.destroy();
		}else if((_level >=20)&&(_level < 30)){
			_levelText.y = _lockbar30.y+12;
			_currentXpText.y = _lockbar30.y+18;
			_lockbar20.destroy();
		}else if((_level >=30)){
			_levelText.y = _lockbar30.y+12;
			_currentXpText.y = _lockbar30.y+18;
			_lockbar30.destroy();
		}

		_currentXpText.x = (_lockbar5.x+_lockbar5.width)-(_currentXpText.width+40);

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

    	
    	FlxG.state.add(_levelText);
    	FlxG.state.add(_currentXpText);
    	updateLockbars();
    }

    private static function clearLocks(){
    	_lockbar5.removeXpBarOverlay();
    	_lockbar10.removeXpBarOverlay();
    	_lockbar20.removeXpBarOverlay();
    	_lockbar30.removeXpBarOverlay();
    }

    private static function updateLockbars(){

    	clearLocks();

    	if(_level < 5){
    		_lockbar5.showXpBarOverlay();
    		_activeLockBar = _lockbar5;
    	}else if((_level >=5) && (_level < 10)){
    		_lockbar10.showXpBarOverlay();
    		_activeLockBar = _lockbar10;
    		
    	}else if((_level >= 10) && (_level < 20)){
    		_lockbar20.showXpBarOverlay();
    		_activeLockBar = _lockbar20;
    		
    	}else if((_level >=20) && (_level < 30)){
    		_lockbar30.showXpBarOverlay();
    		_activeLockBar = _lockbar30;
    		
    	}

    	_activeLockBar.scaleOverlay(getXpRange(),_xpTowardsNextLevel);
    	placeLevelText();
    }

	public function update(){
		_currentXpText.text = Std.string(_xpTowardsNextLevel)+"xp";
		_levelText.text = "Level "+Std.string(_level);
	}


}