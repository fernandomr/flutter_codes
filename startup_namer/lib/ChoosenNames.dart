import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

class ChoosenNames extends StatefulWidget{

  @override
  _ChoosenNamesState createState() => _ChoosenNamesState();
  
}

class _ChoosenNamesState extends State<ChoosenNames>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved suggestions'),
      ),
      // TODO body: ,
    );
  }
}