package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
using flixel.util.FlxSpriteUtil;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class DeckMaker {

	private var Deck:Array<Card> = [];
	private var _hands:Array<Array<Card>> = [];

	public function new(){
		initialize();
		addCardsToDisplay();
		shuffleDeck();
	}

	private function initialize() {
		for( s in 0...4){
			for(c in 0...13){
				var card = new Card(s,c);
				Deck.push(card);
			}
		}
		trace("Deck of "+Deck.length+" created!");
	}

	public function shuffleDeck(){
		var value = Math.floor(Math.random() * 20);
		value = value + 20;
		
		var side1:Array<Card> = Deck.splice(0,value);

		for(x in 0...side1.length){
			var spot = Math.floor(Math.random() * Deck.length);
			Deck.insert(spot, side1[x]);
			//trace(Deck.length+" to spot "+spot);	
		}
	}

	public function deal(number:Int):Array<Card>{
		var cards = Deck.splice(0,number);
		return cards;
	}

	public function discard(cards:Array<Card>){
		for(c in 0...cards.length){
			FlxTween.tween(cards[c],{ x: Card.initialX, y: Card.initialY }, 1.0);
			Deck.push(cards[c]);
		}
		trace("Deck has "+Deck.length+" in it now!");
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