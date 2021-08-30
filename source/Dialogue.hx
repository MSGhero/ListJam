package;

class Dialogue {
	
	public static function getWords(words:Int) {
		
		var temp = new StringBuf();
		var word;
		for (i in 0...words) {
			word = Words.getWord();
			if (i == 0) word = word.charAt(0).toUpperCase() + word.substr(1);
			temp.add(word);
			if (i < words - 1) temp.add(" ");
		}
		
		return temp.toString();
	}
	
	public static function nextText() {
		
		var numWords = Std.random(10) + 1; // at least one word
		var numSentences = Std.random(3) + 1; // at least one sentence
		if (numSentences > numWords) numSentences = numWords; // no less than one word per sentence
		
		var sentenceLengths = [];
		
		for (i in 0...numSentences) {
			sentenceLengths[i] = Std.random(numWords - numSentences) + 1;
			numWords -= sentenceLengths[i];
		}
		
		sentenceLengths[sentenceLengths.length - 1] += numWords; // if something jank happened, add the remaining words to the last sentence
		
		var temp = new StringBuf();
		var r, word;
		for (length in sentenceLengths) {
			
			for (i in 0...length) {
				word = Words.getWord();
				if (i == 0) word = word.charAt(0).toUpperCase() + word.substr(1); // capitalize first letter of each sentence
				temp.add(word);
				if (i < length - 1) temp.add(Math.random() < 0.8 ? " " : ", "); // commas are elegant, add sometimes
			}
			
			r = Math.random();
			temp.add(r < 0.7 ? ". " : r < 0.85 ? "? " : r < 0.95 ? "! " : r < 0.975 ? "??? " : "!!! "); // punctuation
		}
		
		return temp.toString();
	}
}