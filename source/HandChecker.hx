package;

class HandChecker {
	public static function getResult(_hand:Array<Card>):PokerResult{
		var result = PokerResult.None;

		var suitTable = new Map<String,Int>();
		var cardTable = new Map<String,Int>();
		var values = [];

		for(c in 0..._hand.length){
			var card = _hand[c];

			if(suitTable.exists(card.suit)){
				suitTable[card.suit] = suitTable[card.suit]+1;
			}else{
				suitTable.set(card.suit,1);
			}

			if(cardTable.exists(card.label)){
				cardTable[card.label] = cardTable[card.label]+1;
			}else{
				cardTable[card.label] = 1;
			}

			values.push(card.value);
		}

		values.sort(sortFunction);

		if(count(cardTable.keys()) == 4){
			result = PokerResult.Pair;
		}

		return result;
	}

	public static function count(it:Iterator<String>):Int{
		var count = 0;
		while(it.hasNext()){
			it.next();
			count++;
		}
		return count;
	}

	public static function sortFunction(x:Int,y:Int){
		return x-y;
	}
}