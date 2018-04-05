package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
using flixel.util.FlxSpriteUtil;

class LockIcon extends FlxSprite {

	private var _lockLevelText:FlxText;

	public function new(X:Float,Y:Float,bar:LockBar){
		super(X,Y);
		
		this.loadGraphic("assets/images/lock.png");
		this.x = bar.x + bar.width / 2 - (this.width / 2);
		this.y = bar.y + (this.height / 2);
		FlxG.state.add(this);
	}

	public function drawLabel(level:Int){

		if(_lockLevelText == null){
			_lockLevelText = new FlxText(0,0,32,Std.string(level),16,true);
			_lockLevelText.font = "IMPACT";
			FlxG.state.add(_lockLevelText);
		}else{
			_lockLevelText.text =Std.string(level);
		}

			_lockLevelText.x = this.x+(_lockLevelText.width / 2)-((this.width / 2)+5);
			_lockLevelText.y = this.y+(this.height / 2) - (_lockLevelText.height / 2)+8;
			_lockLevelText.alignment = "center";
		
	}

	public override function destroy(){
		FlxG.state.remove(_lockLevelText);
		FlxG.state.remove(this);
	}

}