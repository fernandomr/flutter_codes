import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context){

    return MaterialApp(
      title: 'Startup name generator',
      home: RandomWords(),
    );
  }

}

class RandomWords extends StatefulWidget {
  // this class creates an instance of _RandomWordsState, which extends State
  // class. The StatefulWidget class is immutable and can be thrown away and
  // regenerated, but the State class persists over the lifetime of the widget.
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  // Prefixing an identifier with an underscore enforces privacy in the Dart
  // language and is a recommended best practice for State objects

  final _suggestions = <WordPair>[];
  final _biggerFont = TextStyle(fontSize: 18.0);

  Widget _buildSuggestions(){
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemBuilder: (context, i){

        // For even rows, the function adds a ListTile row for the word pairing

        if (i.isOdd) {
          // for odd rows, adds a Divider widget to visually separate the entries
          return Divider();
        }

        final index = i ~/ 2; // divides i by two and returns an integer result
        if (index >= _suggestions.length){
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

  Widget _buildRow(WordPair pair){
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup name generator'),
      ),
      body: _buildSuggestions(),
    );
  }
}

