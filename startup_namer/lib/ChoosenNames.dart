import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:startup_namer/WordPairModel.dart';

class ChoosenNames extends StatefulWidget{

  @override
  _ChoosenNamesState createState() => _ChoosenNamesState();
  
}

class _ChoosenNamesState extends State<ChoosenNames>{

  var wpModel = new WordPairModel();

  List<Widget> _buildRow(){
    final tiles = wpModel.saved.map<Widget>(
        (WordPair pair){
          return ListTile(
            title: Text(
              pair.asPascalCase,
              style: wpModel.biggerFont,
            ),
          );
        }
    );

    final divided = ListTile.divideTiles(
      context: context,
      tiles: tiles
    ).toList();

    return divided;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved suggestions'),
      ),
      body: ListView(children: _buildRow()),
    );
  }
}