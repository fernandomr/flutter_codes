
import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';

class WordPairModel {

  final _saved = <WordPair>[];
  final biggerFont = TextStyle(fontSize: 18.0);

  get saved => _saved;

  set saved(value) {
    _saved.add(value);
  }

  addListItem(value){
    _saved.add(value);
  }

  removeItem(value){
    _saved.remove(value);
  }
}