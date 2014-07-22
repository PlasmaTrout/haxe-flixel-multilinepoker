package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.effects.FlxSpriteFilter;
import flash.filters.BitmapFilter;
import flixel.tweens.FlxTween;
import flash.filters.GlowFilter;
import flixel.tweens.FlxEase;

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
	public var _spriteFilter:FlxSpriteFilter;
	public var _tween:FlxTween;
	private var _glowFilter:GlowFilter;
	
	public function new(suitnumber:Int,cardnumber:Int) {
		super(initialX,initialY);
		cardNumber = cardnumber;
		suitNumber = suitnumber;
		value = (cardNumber+1)*(suitNumber+1);
		determineCardSuit(suitnumber);
		determineCardLabel(cardnumber);
		var path = "assets/cards/card_"+this.label+this.suit+".png";
		loadGraphic(path);
		_spriteFilter = new FlxSpriteFilter(this,10,10);
		_glowFilter = new GlowFilter(0xFFFFFF, 1, 16, 16, 1.5, flash.filters.BitmapFilterQuality.HIGH,false,false);
		//_tween = FlxTween.tween(_glowFilter , { blurX: 1, blurY: 1},0.3,{ type: FlxTween.PINGPONG });
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

	public function printCard():Void{
		trace("Card: "+this.label+" of "+this.suit);
	}

	public function addFilter():Void{
		
		_spriteFilter.addFilter(_glowFilter);
	}

	public function clearFilters():Void{
		_spriteFilter.removeAllFilters();
		if(_tween != null){
			_tween.destroy();
		}
	}

	public override function update():Void{
		//_spriteFilter.applyFilters();
		

	}

	public function moveBackToOrigin(){

		FlxTween.tween(this,{ x: initialX, y: initialY },1.2,{ease: FlxEase.elasticIn});
	}

}