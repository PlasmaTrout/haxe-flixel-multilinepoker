package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
using flixel.util.FlxSpriteUtil;

class Card extends FlxSprite
{

	public var cardNumber:Int;
	public var label:String;
	public var value:Int;
	public var suit:String;
	public var suitNumber:Int;
	public var symbol:String;
	private var suitList:Array<String> = ["Spades","Hearts","Diamonds","Clubs"];
	private var labels:Array<String> = ["2","3","4","5","6","7","8","9","10","J","Q","K","A"];
	public static var initialX:Int = 1050;
	public static var initialY:Int = 700;

	public function new(suitnumber:Int,cardnumber:Int) {
		super(initialX,initialY);
		cardNumber = cardnumber;
		suitNumber = suitnumber;
		value = (cardNumber+1)*(suitNumber+1);
		determineCardSuit(suitnumber);
		determineCardLabel(cardnumber);
		var path = "assets/cards/card_"+this.label+this.suit+".png";
		loadGraphic(path);
	}
	

	private function determineCardSuit(suitnumber:Int){
		this.suit = suitList[suitnumber];
	}

	private function determineCardLabel(cardnumber:Int){
		this.label = labels[cardnumber];
	}

	public function getCardHash():String{
		return label+suit;
	}

	public function printCard(){
		trace("Card: "+this.label+" of "+this.suit);
	}

}