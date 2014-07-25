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
import flixel.util.FlxSave;
using flixel.util.FlxSpriteUtil;
/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	private var _bg:FlxSprite;

	private var _handManager:HandManager;
	private var _scoreManager:ScoreManager;
	private var _movesManager:MovesManager;
	private var _levelManager:LevelManager;

	private var _discardArea:FlxSprite;
	private var _dealButton:FlxSprite;
	
	private var _maker:DeckMaker;

	private var _hands:Array<Array<Card>> = [];
	private var _clickedCard:HandLocation;
	
	private var _results:Array<PokerResult> = [PokerResult.None,PokerResult.None,PokerResult.None,PokerResult.None,PokerResult.None];
	
	private var _glowFilter:GlowFilter;
	private var _spriteFilter:FlxSpriteFilter;
	
	private var _lineSprite:FlxSprite;
	private var rowPositions:Array<Int> = [100,220,340,450,560];
	private var _dealLocked:Bool = false;
	private var _saveGame:FlxSave;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{

		FlxG.debugger.visible = true;

		_saveGame = new FlxSave();
		_saveGame.bind("LatchDCrazyPoker");

		_bg = new FlxSprite(0,0,"assets/images/Background3.png");
		add(_bg);
		
		initUILayer();	

		_scoreManager = new ScoreManager();
		_movesManager = new MovesManager();
		_levelManager = new LevelManager();
		_handManager = new HandManager(new DeckMaker(),_scoreManager,_movesManager,_levelManager);
		
		_handManager.deal(_levelManager.getLevel());
		

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
		trace("Im being destroyed!!!!");
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		_movesManager.update();
		_scoreManager.update();
		_levelManager.update();
		
		super.update();
	}    

	private function initUILayer():Void{
		

		_dealButton = new FlxSprite();
		_dealButton.loadGraphic("assets/images/DealButton.png");
		_dealButton.x = FlxG.stage.stageWidth - (_dealButton.width+5);
		_dealButton.y = Constants.SCREEN_PAD;
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

	

	private function dealClicked(object:FlxObject):Void{
		if(_handManager.canDeal()){
			_handManager.redeal(_levelManager.getLevel());
			_movesManager.setMoves( _levelManager.getLevel());
		}
	}

	private function discardReleased(object:FlxObject):Void{

		if(_handManager.discardSelectedCard()){
			_movesManager.takeMove();
		}
	}
	
}