package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
using flixel.util.FlxSpriteUtil;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class DeckMaker {

	private var Deck:Array<Card> = [];
	private var _hands:Array<Array<Card>> = [];
	private var _random:FlxRandom;

	public function new(){
		_random = new FlxRandom();

		initialize();
		addCardsToDisplay();
		shuffle(10);
	}

	private function initialize() {
		for( s in 0...4){
			for(c in 0...13){
				var card = new Card(s,c);
				Deck.push(card);
			}
		}
		//trace("Deck of "+Deck.length+" created!");
	}

	public function shuffle(times:Int){
		Deck = _random.shuffleArray(Deck,times);
	}

	public function deal(number:Int):Array<Card>{
		var cards = Deck.splice(0,number);
		cards.sort(cardSort);
		return cards;
	}

	public static function cardSort(a:Card,b:Card){
		if(a.cardNumber > b.cardNumber){
			return -1;
		}
		if(a.cardNumber < b.cardNumber){
			return 1;
		}
		return 0;
	}

	public function discard(cards:Array<Card>){
		for(c in 0...cards.length){
			FlxTween.tween(cards[c],{ x: Card.initialX, y: Card.initialY }, 1.0);
			Deck.push(cards[c]);
		}
		//trace("Deck has "+Deck.length+" in it now!");
	}

	public function addCardsToDisplay(){
		for( c in 0...Deck.length){
			FlxG.state.add(Deck[c]);
		}
	}

	public function removeCardsFromDisplay(){
		for( c in 0...Deck.length){
			FlxG.state.remove(Deck[c]);
		}
	}	

	public function updateCardsVisualOrder(){
		for(c in 0...Deck.length){

		}
	}



}