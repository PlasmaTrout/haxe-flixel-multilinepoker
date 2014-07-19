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
import flixel.plugin.MouseEventManager;
import flash.filters.BitmapFilter;
import flash.filters.BlurFilter;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flixel.effects.FlxSpriteFilter;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil.LineStyle;
using flixel.util.FlxSpriteUtil;
/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	private var _bg:FlxSprite;
	private var _movesSprite:FlxSprite;
	private var _scoreText:FlxText;
	private var _scoreValueText:FlxText;
	private var _movesValueText:FlxText;
	private var _discardArea:FlxSprite;
	private var _dealButton:FlxSprite;
	private var _lockbar5:LockBar;
	private var _lockbar10:LockBar;
	private var _lockbar20:LockBar;
	private var _lockbar30:LockBar;
	private var _maker:DeckMaker;
	private var _level:Int = 5;
	private var _hands:Array<Array<Card>> = [];
	private var _clickedRow = -1;
	private var _clickedCard = -1;
	private var _swipeDirection:SwipeDirection = SwipeDirection.None;
	private var _results:Array<PokerResult> = [PokerResult.None,PokerResult.None,PokerResult.None,PokerResult.None,PokerResult.None];
	private var _floaters:Array<FlxText> = [];
	private var _glowFilter:GlowFilter;
	private var _spriteFilter:FlxSpriteFilter;
	private var _moves:Int;
	private var _lineSprite:FlxSprite;
	private var rowPositions:Array<Int> = [100,220,340,450,560];
	private var _dealLocked:Bool = false;
	private var _score:Int;
	private var _bet:Int;
	
	private var CARD_SPACING:Int=10;
	
	
	private var STD_ORANGE:Int = 0xFFA526;
	private var SCREEN_PAD = 5;
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		_bg = new FlxSprite(0,0,"assets/images/Background3.png");
		add(_bg);
		_score = 50;
		_bet = 10 * _level;
		
		initUILayer();	
		initLockBars();
		initDeck();
		initFloaters();

		deal();

		super.create();

		_lineSprite = new FlxSprite();
		_lineSprite.makeGraphic(FlxG.width,FlxG.height,FlxColor.TRANSPARENT,true);
		
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		_movesValueText.text = Std.string(_moves);
		_scoreValueText.text = Std.string(_score);
		super.update();
	}

    private function initLockBars():Void{
    	_lockbar10 = new LockBar((FlxG.stage.stageWidth/2)-275,rowPositions[2]+25,10);
    	add(_lockbar10);

    	_lockbar5 = new LockBar(_lockbar10.x,rowPositions[1]+25,5);
    	add(_lockbar5);

    	_lockbar20 = new LockBar(_lockbar10.x,rowPositions[3]+25,20);
    	add(_lockbar20);

    	_lockbar30 = new LockBar(_lockbar20.x,rowPositions[4]+25,30);
    	add(_lockbar30);
    }

    private function initFloaters():Void{
    	for(v in 0...5){
    		var floaty = new FlxText(0, 0, -1, "Floater" , 100 , true );
    		floaty.font = "IMPACT";
    		floaty.screenCenter();
 
 			floaty.alpha = 0;
    		floaty.y = rowPositions[v]+30;
    		add(floaty);

    		_floaters.push(floaty);
    	}
    }

	private function initUILayer():Void{
		_movesSprite = new FlxSprite();
		_movesSprite.loadGraphic("assets/images/MovesLeftCountBox.png");
		_movesSprite.x = (FlxG.stage.stageWidth / 2) - (_movesSprite.width / 2);
		_movesSprite.y = SCREEN_PAD;
		add(_movesSprite);

		_scoreText = new FlxText(SCREEN_PAD, SCREEN_PAD ,-1,"SCORE",36,true);
		_scoreText.font = "IMPACT";
		_scoreText.color = STD_ORANGE;
		add(_scoreText);

		_scoreValueText = new FlxText(_scoreText.width+10,SCREEN_PAD,-1,"$0",36,true);
		_scoreValueText.font = "IMPACT";
		add(_scoreValueText);

		_movesValueText = new FlxText(572,SCREEN_PAD+1,50,"5",36,true);
		_movesValueText.font = "IMPACT";
		_movesValueText.color = STD_ORANGE;
		_movesValueText.alignment = "center";
		add(_movesValueText);

		_dealButton = new FlxSprite();
		_dealButton.loadGraphic("assets/images/DealButton.png");
		_dealButton.x = FlxG.stage.stageWidth - (_dealButton.width+5);
		_dealButton.y = SCREEN_PAD;
		add(_dealButton);

		

		_discardArea = new FlxSprite();
		_discardArea.loadGraphic("assets/images/discardarea2.png");
		_discardArea.x =  50;
		_discardArea.y = 120;
		add(_discardArea);


		MouseEventManager.add( _dealButton , dealClicked);

		// The discard area has transparencies. In flixel if the alpha channel is set then
		// clicks won't register on the transparent part. Have to hide an object underneath it
		// to catch them.
		var invisDiscardBox = new FlxObject();
		//invisDiscardBox.visible = false;
		invisDiscardBox.x = _discardArea.x;
		invisDiscardBox.y = _discardArea.y;
		invisDiscardBox.height = _discardArea.height;
		invisDiscardBox.width = _discardArea.width;

		add(invisDiscardBox);
		MouseEventManager.add( invisDiscardBox , null , discardReleased);
	}	

	private function initDeck():Void{
		_maker = new DeckMaker();
	}

	private function dealClicked(object:FlxObject):Void{
		if(!_dealLocked){

			for(h in 0..._hands.length){
				var discard = _hands[h].splice(0,5);
				_maker.discard(discard);
			}
			resetFloaters();
			_hands.splice(0,_hands.length);

		
			deal();	
		}
	}

	private function deal():Void{
		_score = _score - _bet;

		_dealLocked = true;
		resetSelection();
		_maker.shuffle(10);

		_hands.push(new Array<Card>());

		if(_level >= 5){
			_hands.push(new Array<Card>());
		}

		if(_level >= 10){
			_hands.push(new Array<Card>());
		}

		if(_level >= 20){
			_hands.push(new Array<Card>());
		}

		if(_level >=30){
			_hands.push(new Array<Card>());
		}

		for(h in 0..._hands.length){
			_hands[h] = _maker.deal(5);
		}

		if(_level > 5){
			_moves = 2 * _hands.length;
		}else{
			_moves = 2+(_level - 1);
		}

		animateHands();
	}

	private function discardReleased(object:FlxObject):Void{
		if(_clickedRow != -1 && _clickedCard != -1){
			var card = _hands[_clickedRow][_clickedCard];
			_maker.discard([card]);
			
			var newHand = _maker.deal(1);
			_hands[_clickedRow][_clickedCard] = newHand[0];
			_hands[_clickedRow].sort(DeckMaker.cardSort);
			_moves--;
			animateHands();

			resetSelection();
		}
	}
	
	private function resetSelection():Void{
		
		if(_clickedRow != -1 && _clickedCard != -1){
			_hands[_clickedRow][_clickedCard].clearFilters();
		}
		_clickedRow = -1;
		_clickedCard = -1;	


	}

	private function resetFloaters():Void{
		for(f in 0..._floaters.length){
			_floaters[f].screenCenter(true,false);
			_floaters[f].size = 100;
			_floaters[f].alpha = 0;
		}	
	}

	private function animateHands():Void{
		
		var horizontalPositions = [0,0,0,0,0];
		

		horizontalPositions[2] = Std.int(FlxG.stage.stageWidth / 2)- 50;
		horizontalPositions[1] = horizontalPositions[2] - 100 - CARD_SPACING;
		horizontalPositions[0] = horizontalPositions[1] - 100 - CARD_SPACING;
		horizontalPositions[3] = horizontalPositions[2] + 100 + CARD_SPACING;
		horizontalPositions[4] = horizontalPositions[3] + 100 + CARD_SPACING;
		var delay = 0.01;

		for(row in 0..._hands.length){
			for(card in 0..._hands[row].length){
				var currentCard = _hands[row][card];
				
				//trace("Animating card "+card+" in row "+row);
				if(row == (_hands.length-1) && card == 4){
					FlxTween.tween(currentCard,{ x: horizontalPositions[card], y: rowPositions[row]},
					1.2,{ease: FlxEase.elasticOut, startDelay: delay, complete: dealComplete });
				}else{
					currentCard.centerOrigin();
					FlxTween.tween(currentCard,{ x: horizontalPositions[card], y: rowPositions[row]},
					1.2,{ease: FlxEase.elasticOut, startDelay: delay});
				}
				
				delay = delay + 0.03;
				MouseEventManager.add(currentCard, cardClicked,cardReleased,cardEnter,cardLeave);
			}
		}
	}

	private function dealComplete(tween:FlxTween):Void{
		trace("deal completed!");
		checkHands();
		_dealLocked = false;
	}

	private function cardEnter(object:FlxObject){
		
	}

	private function cardLeave(object:FlxObject){
		
	}

	private function cardClicked(object:FlxObject):Void{

		if(_moves > 0){
			resetSelection();
			var card = cast(object,Card);
			for(row in 0..._hands.length){
				var index = _hands[row].indexOf(card);
				if(index != -1){
					_clickedRow = row;
					_clickedCard = index;
					card.addFilter();
					break;
				}
			}
		}else{
			_moves = 0;
			
		}

		trace("Clicked Row:"+_clickedRow+" Card:"+_clickedCard);
	}

	private function cardReleased(object:FlxObject):Void{
		
		var swipe = FlxG.swipes[0];
	
		if (swipe != null && _moves > 0){
		if(swipe.distance <= 150 && swipe.distance > 10){
			if(swipe.angle < 0){
				if(swipe.angle >= -45){
					_swipeDirection = SwipeDirection.Up;
				}else if(swipe.angle <= -135){
					_swipeDirection = SwipeDirection.Down;
				}else{
					_swipeDirection = SwipeDirection.Left;
				}
			}else{
				if(swipe.angle <= 45){
					_swipeDirection = SwipeDirection.Up;
				}else if(swipe.angle >= 135){
					_swipeDirection = SwipeDirection.Down;
				}else{
					_swipeDirection = SwipeDirection.Right;
				}
			}
			
			swapCards();
			trace("Swiped "+_swipeDirection+" angle "+swipe.angle+" distance "+swipe.distance);
			}
		}
	}

	private function checkHands(){
		for(h in 0..._hands.length){
			var result = HandChecker.getResult(_hands[h]);
			if(result != _results[h]){
				_results[h] = result;
				_floaters[h].alpha = 0;
				_floaters[h].size = 100;
				_floaters[h].screenCenter(true,false);

				var score = getScore(result);
				addScore(score,h);
			}
			

		}

		for(r in 0..._results.length){
			if(_results[r] != PokerResult.None){
				_floaters[r].alpha = 1;
				_floaters[r].text = Std.string(_results[r]);
				

				
				FlxTween.tween(_floaters[r],{ size: 48, x: 800 },0.1,{ ease: FlxEase.bounceOut });
			}else{
				_floaters[r].alpha = 0;
				_floaters[r].screenCenter(true,false);
			}
		}
	}

	private function addScore(score:Int,floater:Int){
		var scoreText = new FlxText( _floaters[floater].x , _floaters[floater].y , -1 , "+"+Std.string(score) , 48 , true);
		scoreText.color = FlxColor.RED;
		scoreText.font = "IMPACT";
		add(scoreText);

		/*FlxTween.tween(scoreText,{ x: _scoreValueText.x, y: _scoreValueText.y, size: 48 },0.5,
		 { complete: function(x){
		 		remove(scoreText);
		 		_score = _score+score;
		 	} });*/
		FlxTween.cubicMotion( scoreText , 800 , scoreText.y ,
		 1024, 50, 100 , 10 ,
		  _scoreValueText.x , 10, 1.0 ,
		   { complete: function(x){
		   		remove(scoreText);
		   		var newScore = _score+score;
		   		FlxTween.num(_score,newScore,0.2,{},function(x){
		   			_score = Std.int(x);
		   		});
		   	}});
	}

	private function swapCards(){
		var cardA = _hands[_clickedRow][_clickedCard];
		var cardB:Card = null;



		if(_clickedCard <= 3 && _swipeDirection == SwipeDirection.Right){
			cardB = _hands[_clickedRow][_clickedCard+1];
			_hands[_clickedRow][_clickedCard] = cardB;
			_hands[_clickedRow][_clickedCard+1] = cardA;
		}

		if(_clickedCard > 0 && _swipeDirection == SwipeDirection.Left){
			cardB = _hands[_clickedRow][_clickedCard-1];
			_hands[_clickedRow][_clickedCard] = cardB;
			_hands[_clickedRow][_clickedCard-1] = cardA;
		}

		if(_clickedRow <= 3 && _swipeDirection == SwipeDirection.Down){
			cardB = _hands[_clickedRow+1][_clickedCard];
			_hands[_clickedRow][_clickedCard] = cardB;
			_hands[_clickedRow+1][_clickedCard] = cardA;
		}

		if(_clickedRow > 0 && _swipeDirection == SwipeDirection.Up){
			cardB = _hands[_clickedRow-1][_clickedCard];
			_hands[_clickedRow][_clickedCard] = cardB;
			_hands[_clickedRow-1][_clickedCard] = cardA;
		}

		if(cardB != null){
			FlxTween.tween(cardA,{ x: cardB.x, y: cardB.y },0.1);
			FlxTween.tween(cardB,{ x: cardA.x, y: cardA.y },0.1);
			trace("Swapping "+cardA.label+" with "+cardB.label);
		}

		_moves--;
		cardA.clearFilters();
		cardB.clearFilters();
		checkHands();

		resetSelection();
	}

	private function getScore(presult:PokerResult):Int{
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

		return result;
	}
}