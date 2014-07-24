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

class MovesManager {
	private var _movesSprite:FlxSprite;
	private var _movesValueText:FlxText;
	private var _moves:Int;

	public function new(?moves:Int=2){
		_movesSprite = new FlxSprite();
		_movesSprite.loadGraphic("assets/images/MovesLeftCountBox.png");
		_movesSprite.x = (FlxG.stage.stageWidth / 2) - (_movesSprite.width / 2);
		_movesSprite.y = Constants.SCREEN_PAD;
		FlxG.state.add(_movesSprite);

		_movesValueText = new FlxText(572,Constants.SCREEN_PAD+1,50,"5",36,true);
		_movesValueText.font = "IMPACT";
		_movesValueText.color = Constants.STD_ORANGE;
		_movesValueText.alignment = "center";
		FlxG.state.add(_movesValueText);

		_moves = moves;
	}

	public function takeMove(){
		_moves = _moves - 1;
	}

	public function canMove():Bool{
		return _moves > 0;
	}

	public function addMoves(moves:Int){
		_moves = _moves+moves;
	}

	public function setMoves(_level:Int){
		if(_level > 5){
			_moves = 2 + Std.int((_level / 5));
		}else{
			_moves = 2;
		}
	}

	public function update():Void
	{
		_movesValueText.text = Std.string(_moves);
	}
}