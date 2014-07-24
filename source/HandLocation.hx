package;

class HandLocation {
	public var _x:Int;
	public var _y:Int;

	public function new(?x:Int=-1,?y:Int=-1){
		this._x = x;
		this._y = y;
	}

	public function pullCard(hand:Array<Array<Card>>):Card{
		var card = null;
		//trace("trying to get row "+_y+" and card "+_x);
		card = hand[_y][_x];

		return card;
	}

	public function reset(){
		_x = -1;
		_y = -1;
	}

	public function hasValidSelection():Bool{
		return (_x != -1) && (_y != -1);
	}

	public function putCard(hand:Array<Array<Card>>,card:Card):Void{
		hand[_y][_x] = card;
	}

	public function hasCardToLeft():Bool{
		return _x > 0;
	}

	public function pullCardToLeft():HandLocation{
		return new HandLocation(_x-1,_y);
	}

	public function hasCardToRight():Bool{
		return _x < 5;
	}

	public function pullCardToRight():HandLocation{
		return new HandLocation(_x+1,_y);
	}

	public function hasCardBelow():Bool{
		return _y < 5;
	}

	public function pullCardBelow():HandLocation{
		return new HandLocation(_x,_y+1);
	}

	public function hasCardAbove():Bool{
		return _y > 0;
	}

	public function pullCardAbove():HandLocation{
		return new HandLocation(_x,_y-1);
	}
}