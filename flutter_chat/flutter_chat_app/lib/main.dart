import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/flutterChatModel.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(body: FlutterChatMain()),
    );
  }
}

class FlutterChatMain extends StatefulWidget {
  FlutterChatMain({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _FlutterChatMainState createState() => _FlutterChatMainState();
}

class _FlutterChatMainState extends State<FlutterChatMain> {

  void startUp() async {
    Directory docsDir = await getApplicationDocumentsDirectory();
    model.docsDir = docsDir;

    var credentialsFile = File(join(model.docsDir.path, "credentials"));
    var exists = await credentialsFile.exists();

    var credentials;
    if (exists){
      credentials = credentialsFile.readAsString();
      List credParts = credentials.split("============");
      LoginDialog().validateWithStoredCredentials(credParts[0], credParts[1]);
    } else {
      await showDialog(context: model.rootBuildContext,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return LoginDialog();
          }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    startUp();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'App being built',
            ),
          ],
        ),
      ),
    );
  }
}
