// Individual word counts
var mapper = function () {
    for (var i = 0; i < this.content.length; i++) {
        var temp = this.content[i].split(" ");
        for (var x = 0; x < temp.length; x++) {
            temp[x] = temp[x].replace(/(\r\n|\n|\r)/gm, "");
            temp[x] = temp[x].replace(/[\.,\/#!$%\^&\*;:{}=\_~()]/g, "");
            temp[x] = temp[x].replace(/\x22/g,"");
            temp[x] = temp[x].toLowerCase();
            if (temp[x] != "" && /[a-z0-9]/i.test(temp[x])) {
                emit(temp[x], 1);
            }
        }
    }
};

// Count by date
var mapper = function () {
  var standardTime = new Date(this.pubDate *1000);
  emit(standardTime.toLocaleDateString(), 1);
};

// Count by weekday
var mapper = function () {
  var standardTime = new Date(this.pubDate *1000);
  emit(standardTime.getDay(), 1);
};


var mapper = function () {
    for (var i = 0; i < this.content.length; i++) {
        var temp = this.content[i].split(" ");
        for (var x = 0; x < temp.length; x++) {
            temp[x] = temp[x].replace(/(\r\n|\n|\r)/gm, "");
            temp[x] = temp[x].replace(/[\.,\/#!$%\^&\*;:{}=\_~()]/g, "");
            temp[x] = temp[x].replace(/\x22/g,"");
            temp[x] = temp[x].toLowerCase();
            var letters = temp[x].split("");
            for (var n = 0; n < letters.length; n++) {
              if (letters[n] != "" && /[a-z0-9]/i.test(letters[n])) {
                  emit(letters[n], 1);
              }
            }
        }
    }
};

// map bigrams
var mapper = function() {
    var content = this.content;
    for (var a = 0; a < content.length; a++) {
        var sentence = content[a].toLowerCase();
        var words = sentence.split(" ");
        for (var c = 0; c < words.length; c++) {
          words[c] = words[c].replace(/(\r\n|\n|\r)/gm, "");
          words[c] = words[c].replace(/[\.,\/#!…“”•\^&\*;:{}=\_~()\–\-\+]/g, "");
          words[c] = words[c].replace(/\x22/g,"");
        }

        for (var b = 0; b < words.length-1; b++) {
            var gram = "";
            gram = words[b] + " " + words[b+1];
            if (/[a-z0-9]/i.test(gram) && words[b] != "" && words[b] != null) {
              emit(gram, 1);
            }
        }
    }
}

// map trigrams
var mapper = function() {
    var content = this.content;
    for (var a = 0; a < content.length; a++) {
        var sentence = content[a].toLowerCase();
        var words = sentence.split(" ");
        for (var c = 0; c < words.length; c++) {
          words[c] = words[c].replace(/(\r\n|\n|\r)/gm, "");
          words[c] = words[c].replace(/[\.,\/#!…“”•\^&\*;:{}=\_~()\–\-\+]/g, "");
          words[c] = words[c].replace(/\x22/g,"");
        }

        for (var b = 0; b < words.length-2; b++) {
            var gram = "";
            gram = words[b] + " " + words[b+1] + " " + words[b+2];
            if (words[b] != "" && words[b+1] != "" && words[b+2] != "") {
              emit(gram, 1);
            }
        }
    }
}

var reducer = function (key, values) {
    var count = 0;
    for (index in values) {
        count += values[index];
    }
    return count;
};

db.collectionname.mapReduce(mapper, reducer, {out: "bigrams", limit: 2000});
db.ngrams.find().sort({value: -1})
db.ngrams.drop()
