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

	private var _handManager:HandManager;
	private var _scoreManager:ScoreManager;
	private var _movesManager:MovesManager;

	private var _discardArea:FlxSprite;
	private var _dealButton:FlxSprite;
	private var _lockbar5:LockBar;
	private var _lockbar10:LockBar;
	private var _lockbar20:LockBar;
	private var _lockbar30:LockBar;
	private var _maker:DeckMaker;
	private var _level:Int = 5;
	private var _hands:Array<Array<Card>> = [];
	private var _clickedCard:HandLocation;
	
	private var _results:Array<PokerResult> = [PokerResult.None,PokerResult.None,PokerResult.None,PokerResult.None,PokerResult.None];
	
	private var _glowFilter:GlowFilter;
	private var _spriteFilter:FlxSpriteFilter;
	
	private var _lineSprite:FlxSprite;
	private var rowPositions:Array<Int> = [100,220,340,450,560];
	private var _dealLocked:Bool = false;
	
	

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		_bg = new FlxSprite(0,0,"assets/images/Background3.png");
		add(_bg);
		
		initUILayer();	
		initLockBars();

		_scoreManager = new ScoreManager(50);
		_movesManager = new MovesManager();
		_handManager = new HandManager(new DeckMaker(),_scoreManager,_movesManager);
		_handManager.deal(_level);
		

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
		_movesManager.update();
		_scoreManager.update();
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
			_handManager.redeal(_level);
			_movesManager.setMoves( _level);
		}
	}

	private function discardReleased(object:FlxObject):Void{
		_movesManager.takeMove();
		_handManager.discardSelectedCard();
	}
	
}