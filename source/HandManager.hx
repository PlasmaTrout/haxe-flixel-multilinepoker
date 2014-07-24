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
import flixel.util.FlxSave;
using flixel.util.FlxSpriteUtil;
import flixel.plugin.MouseEventManager;

class HandManager {
	
	public static var _deck:DeckMaker;
	public static var _hands:Array<Array<Card>> = [];
	public var _clickedLocation:HandLocation;
	public var _swapLocation:HandLocation;
	private var _isDealLocked:Bool;
	private var _scoreManager:ScoreManager;
	private var _movesManager:MovesManager;
	private var _levelManager:LevelManager;
	private var _swipeDirection:SwipeDirection = SwipeDirection.None;
	private var _saveGame:FlxSave;

	private static var rowPositions:Array<Int> = [100,220,340,450,560];
	

	public function new(deck:DeckMaker,score:ScoreManager,moves:MovesManager,lm:LevelManager){
		_deck = deck;
		_scoreManager = score;
		_isDealLocked = false;
		_clickedLocation = new HandLocation();
		_swapLocation = new HandLocation();
		_movesManager = moves;
		_levelManager = lm;
		_saveGame = new FlxSave();
		_saveGame.bind("LatchDCrazyPoker");
		LevelManager._levelSignal.add(levelAdvanceCallback);

	}

	public function levelAdvanceCallback(level:Int){
		if(level == 5 || level == 10 || level == 20 || level == 30){
			addRow();
			_movesManager.addMoves(2);
		}
		_saveGame.data.level = level;
		_saveGame.flush();
	}

	public function canDeal():Bool{
		return !_isDealLocked;
	}

	public function deal(_level:Int):Void{

		resetSelection();
		
		_isDealLocked = true;
		resetSelection();
		_deck.shuffle(10);

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
			_hands[h] = _deck.deal(5);
		}

		animateHands();
	}

	public function redeal(_level:Int):Void{
		for(h in 0..._hands.length){
			var discard = _hands[h].splice(0,5);
			_deck.discard(discard);
		}
		_hands.splice(0,_hands.length);
		_scoreManager.resetFloaters();
		deal(_level);
	}

	private function checkHands(){
		for(h in 0..._hands.length){
			var result = HandChecker.getResult(_hands[h]);
			_scoreManager.setScore(result,h);
		}

	}

	private function resetSelection():Void{
		for(x in 0..._hands.length){
			for(y in 0..._hands[x].length){
				_hands[x][y].clearFilters();
			}
		}
		_clickedLocation.reset();
	}

	private function findSelection(card:Card):HandLocation{

		var location = new HandLocation();

		for(row in 0..._hands.length){
			var index = _hands[row].indexOf(card);
			
			if(index != -1){
				location._y = row;
				location._x = index;
				card.addFilter();
				break;
			}
		}

		return location;
	}

	public function discardSelectedCard():Bool{

		var discarded = false;

		if(_clickedLocation.hasValidSelection()){
			var card = _clickedLocation.pullCard(_hands);
			_deck.discard([card]);
			
			var newHand = _deck.deal(1);
			_clickedLocation.putCard(_hands, newHand[0]);
			_hands[_clickedLocation._y].sort(DeckMaker.cardSort);
			
			animateHands();
			discarded = true;
			resetSelection();
		}

		return discarded;
	}

	public function addRow(){
		_hands.push(_deck.deal(5));
		animateHands();
	}

	private function animateHands():Void{
		
		var horizontalPositions = [0,0,0,0,0];
		
		horizontalPositions[2] = Std.int(FlxG.stage.stageWidth / 2)- 50;
		horizontalPositions[1] = horizontalPositions[2] - 100 - Constants.CARD_SPACING;
		horizontalPositions[0] = horizontalPositions[1] - 100 - Constants.CARD_SPACING;
		horizontalPositions[3] = horizontalPositions[2] + 100 + Constants.CARD_SPACING;
		horizontalPositions[4] = horizontalPositions[3] + 100 + Constants.CARD_SPACING;
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
		checkHands();
		_isDealLocked = false;
	}

	private function cardClicked(object:FlxObject):Void{
		//trace("Click on "+object);
		if(_movesManager.canMove()){
			
			// If there is a pre-existing selection and another care is clicked
			// on. See if the new card is only a row or card away. If so swap them
			// out. (This helps with controller logic later)
			if(_clickedLocation.hasValidSelection()){
				resetSelection();
			}

			var card = cast(object,Card);
			_clickedLocation = findSelection(card);
			//trace(_clickedLocation);

		}

		//trace("Clicked Row:"+_clickedRow+" Card:"+_clickedCard);
	}

	private function cardReleased(object:FlxObject):Void{
		
		var swipe = FlxG.swipes[0];
	
		if (swipe != null && _movesManager.canMove()){
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
			//trace("Swiped "+_swipeDirection+" angle "+swipe.angle+" distance "+swipe.distance);
			}
		}
	}

	private function swapCards(){
		var cardA = _clickedLocation.pullCard(_hands);
		var cardB:Card = null;

		if(_swipeDirection == SwipeDirection.Right && _clickedLocation.hasCardToRight()){
			_swapLocation = _clickedLocation.pullCardToRight();
		}

		if(_swipeDirection == SwipeDirection.Left && _clickedLocation.hasCardToLeft()){
			_swapLocation = _clickedLocation.pullCardToLeft();
		}

		if(_swipeDirection == SwipeDirection.Down && _clickedLocation.hasCardBelow()){
			_swapLocation = _clickedLocation.pullCardBelow();
		}

		if(_swipeDirection == SwipeDirection.Up && _clickedLocation.hasCardAbove()){
			_swapLocation = _clickedLocation.pullCardAbove();
		}

		if(_swapLocation != null && _swapLocation.hasValidSelection()){
			cardB = _swapLocation.pullCard(_hands);

			if(cardB != null){
				_clickedLocation.putCard(_hands,cardB);
				_swapLocation.putCard(_hands,cardA);

				FlxTween.tween(cardA,{ x: cardB.x, y: cardB.y },0.1);
				FlxTween.tween(cardB,{ x: cardA.x, y: cardA.y },0.1);
			}
		}

		_movesManager.takeMove();

		cardA.clearFilters();
		
		if(cardB != null){
			cardB.clearFilters();
		}

		checkHands();

		resetSelection();
	}

	private function cardEnter(object:FlxObject){
		
	}

	private function cardLeave(object:FlxObject){
		
	}

	
}