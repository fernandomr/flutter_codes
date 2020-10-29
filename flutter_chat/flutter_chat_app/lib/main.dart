import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/flutterChatModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scoped_model/scoped_model.dart';

void main() {
  runApp(FlutterChatMain());
}

class FlutterChatMain extends StatelessWidget {
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
    model.rootBuildContext = context;
    startUp();

    return ScopedModel<FlutterChatModel>(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
          builder: (
              BuildContext context,
              Widget inChild,
              FlutterChatModel inModel
              ) {
            return MaterialApp(
              initialRoute: "/",
              routes: {
                "/Lobby": (screenContext) => Lobby(),
                "/Room": (screenContext) => Room(),
                "/UserList": (screenContext) => UserList(),
                "/CreateRoom": (screenContext) => CreateRoom(),
              },
              home: Home(),
            );
          }
      ),
    );
  }
}
