package;

class HandChecker {
	public static function getResult(_hand:Array<Card>):PokerResult{
		var result = PokerResult.None;

		var suitTable = new Map<String,Int>();
		var cardTable = new Map<String,Int>();
		var values = [0,0,0,0,0];

		for(c in 0..._hand.length){
			var card = _hand[c];
			values[c] = card.cardNumber;

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

			
		}
		
		values.sort(sortFunction);
		
		if(count(cardTable.keys()) == 4){
			result = PokerResult.Pair;
		}

		if(count(cardTable.keys()) == 2){
			if(highestValue(cardTable) == 4){
				result = PokerResult.FourOfAKind;
			}else{
				result = PokerResult.FullHouse;
			}
		}

		if(count(cardTable.keys()) == 3){
			if(highestValue(cardTable) == 3){
				result = PokerResult.Triple;
			}else{
				result = PokerResult.TwoPair;
			}
		}

		if(count(suitTable.keys()) == 1){
			result = PokerResult.Flush;
		}

		var straight = hasStraight(values);

		if(straight){
			if(result == PokerResult.Flush){
				result = PokerResult.StraightFlush;
			}else{
				result = PokerResult.Straight;
			}
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

	public static function highestValue(map:Map<String,Int>):Int{
		var highest = 0;
		var it = map.keys();

		while(it.hasNext()){
			var key = it.next();
			if(map[key] > highest){
				highest = map[key];
			}
		}

		return highest;
	}

	public static function hasStraight(values:Array<Int>):Bool{
		var hasStraight = false;

		var diff = 0;
		var previous = -1;
		var cardInOrder = 0;
		trace(values);
		for(x in 0...values.length){
			
			if(previous == -1){
				previous = values[x];
				trace("first card is "+previous);
				cardInOrder++;
			}else{
				diff = values[x] - previous;
				trace(diff);
				previous = values[x];
				if(diff == 1){
					cardInOrder++;
				}else{
					
				}
			}
		}


		if(cardInOrder == 5){
			hasStraight = true;
		}

		trace("Cards in order "+cardInOrder);
		return hasStraight;
	}

	public static function sortFunction(x:Int,y:Int){
		if(x < y) { return -1; }
		if(x > y) { return 1; }
		return 0;
	}
}