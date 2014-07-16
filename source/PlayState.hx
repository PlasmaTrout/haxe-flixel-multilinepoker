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
	private var _level:Int = 30;
	private var _hands:Array<Array<Card>> = [];
	private var _clickedRow = -1;
	private var _clickedCard = -1;
	private var _swipeDirection:SwipeDirection = SwipeDirection.None;

	
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

		initUILayer();	
		initLockBars();
		initDeck();
		deal();

		super.create();
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
		for(swipe in FlxG.swipes){
	
		if(swipe.distance <= 150){
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

		super.update();
	}

    private function initLockBars():Void{
    	_lockbar10 = new LockBar(0,0,10);
    	_lockbar10.centerScreen();
    	add(_lockbar10);

    	_lockbar5 = new LockBar(_lockbar10.x,_lockbar10.y - 100,5);
    	add(_lockbar5);

    	_lockbar20 = new LockBar(_lockbar10.x,_lockbar10.y + 100,20);
    	add(_lockbar20);

    	_lockbar30 = new LockBar(_lockbar20.x,_lockbar20.y + 100,30);
    	add(_lockbar30);
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

		
	}	

	private function initDeck():Void{
		_maker = new DeckMaker();

	}

	private function dealClicked(event:Event):Void{
		trace("Deal clicked!");
	}

	private function deal():Void{

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

		animateHands();
	}

	private function animateHands():Void{
		
		var horizontalPositions = [0,0,0,0,0];
		var rowPositions = [100,220,340,450,560];

		horizontalPositions[2] = Std.int(FlxG.stage.stageWidth / 2)- 50;
		horizontalPositions[1] = horizontalPositions[2] - 100 - CARD_SPACING;
		horizontalPositions[0] = horizontalPositions[1] - 100 - CARD_SPACING;
		horizontalPositions[3] = horizontalPositions[2] + 100 + CARD_SPACING;
		horizontalPositions[4] = horizontalPositions[3] + 100 + CARD_SPACING;
		var delay = 0.01;

		for(row in 0..._hands.length){
			for(card in 0..._hands[row].length){
				var currentCard = _hands[row][card];
				//currentCard.x = horizontalPositions[card];
				//currentCard.y = rowPositions[row];
				FlxTween.tween(currentCard,{ x: horizontalPositions[card], y: rowPositions[row]},
					1.0,{ease: FlxEase.backOut, startDelay: delay});
				delay = delay + 0.01;
				MouseEventManager.add(currentCard, cardClicked);
			}
		}
		
		
	}

	private function cardClicked(object:FlxObject):Void{
		var card = cast(object,Card);
		for(row in 0..._hands.length){
			var index = _hands[row].indexOf(card);
			if(index != -1){
				_clickedRow = row;
				_clickedCard = index;
				break;
			}
		}

		trace("Clicked Row:"+_clickedRow+" Card:"+_clickedCard);
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
		}
	}
}