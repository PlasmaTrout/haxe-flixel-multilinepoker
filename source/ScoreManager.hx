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
using flixel.util.FlxSpriteUtil;

class ScoreManager {
	private var _floaters:Array<FlxText> = [];
	private var rowPositions:Array<Int> = [100,220,340,450,560];
	private var _scoreText:FlxText;
	private var _scoreValueText:FlxText;
	private var _score:Int;
	private var _bet:Int;
	private var _previousResult:Array<PokerResult>;
	

	public function new(?score:Int=0){
		
		_score = score;

		_scoreText = new FlxText(Constants.SCREEN_PAD, Constants.SCREEN_PAD ,-1,"SCORE",36,true);
		_scoreText.font = "IMPACT";
		_scoreText.color = Constants.STD_ORANGE;
		FlxG.state.add(_scoreText);

		_scoreValueText = new FlxText(_scoreText.width+10,Constants.SCREEN_PAD,-1,"$0",36,true);
		_scoreValueText.font = "IMPACT";
		FlxG.state.add(_scoreValueText);
		_bet = 1;
		_previousResult = [PokerResult.None,PokerResult.None,PokerResult.None,PokerResult.None,PokerResult.None];
		initFloaters();

	}

	public function resetFloaters():Void{
		for(f in 0..._floaters.length){
			_floaters[f].screenCenter(true,false);
			_floaters[f].size = 100;
			_floaters[f].alpha = 0;
			_previousResult[f] = PokerResult.None;
		}	
	}

	private function initFloaters():Void{
    	for(v in 0...5){
    		var floaty = new FlxText(0, 0, -1, "Floater" , 100 , true );
    		floaty.font = "IMPACT";
    		floaty.screenCenter();
 
 			floaty.alpha = 0;
    		floaty.y = rowPositions[v]+30;
    		FlxG.state.add(floaty);

    		_floaters.push(floaty);
    	}
    }

    private function addScore(score:Int,floater:Int){
		var scoreText = new FlxText( _floaters[floater].x , _floaters[floater].y , -1 , "+"+Std.string(score) , 42 , true);
		//scoreText.color = FlxColor.YELLOW;
		scoreText.font = "IMPACT";
		FlxG.state.add(scoreText);

		/*FlxTween.tween(scoreText,{ x: _scoreValueText.x, y: _scoreValueText.y, size: 48 },0.5,
		 { complete: function(x){
		 		remove(scoreText);
		 		_score = _score+score;
		 	} });*/
		FlxTween.cubicMotion( scoreText , 800 , scoreText.y ,
		 1024, 50, 100 , 10 ,
		  _scoreValueText.x+50 , 0, 1.0 ,
		   { complete: function(x){
		   		FlxG.state.remove(scoreText);
		   		var newScore = _score+score;
		   		FlxTween.num(_score,newScore,0.2,{ ease: FlxEase.cubeInOut},function(x){
		   			_score = Std.int(x);

		   		});
		   	}});
	}

	private function animateScore(result:PokerResult,r:Int):Void{
		if(result != PokerResult.None){
			_floaters[r].alpha = 1;
			_floaters[r].text = Std.string(result);
			FlxTween.tween(_floaters[r],{ size: 48, x: 800 },0.1,{ ease: FlxEase.bounceOut });
		}else{
			_floaters[r].alpha = 0;
			_floaters[r].screenCenter(true,false);
		}
	}

	public function setScore(presult:PokerResult,row:Int):Void{
		var result = 0;

		switch(presult){
			case PokerResult.Pair:
				result = _bet;
			case PokerResult.TwoPair:
				result = _bet*2;
			case PokerResult.Triple:
				result = _bet*3;
			case PokerResult.Straight:
				result = _bet*5;
			case PokerResult.Flush:
				result = _bet*8;
			case PokerResult.StraightFlush:
				result = _bet*50;
		    case PokerResult.FullHouse:
		    	result = _bet*10;
			case PokerResult.RoyalFlush:
				result = _bet*200;
			case PokerResult.FourOfAKind:
				result = _bet*40;
			case PokerResult.None:
		}

		if(presult != PokerResult.None && Type.enumIndex(presult) > Type.enumIndex(_previousResult[row])){
			animateScore(presult,row);
			this.addScore(result,row);
			_previousResult[row] = presult;
			LevelManager.addXP(presult);
		}
	}

	public function update():Void
	{
		_scoreValueText.text = Std.string(_score);
	}
}