import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/flutterChatModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scoped_model/scoped_model.dart';

class LoginDialog extends StatelessWidget {
  static final GlobalKey<FormState> _loginFormKey = new GlobalKey<FormState>();

  String _userName;
  String _password;

  Widget build(final BuildContext context){
    return ScopedModel<FlutterChatModel>(
        model: model,
        child: ScopedModelDescendant<FlutterChatModel>(
          builder: (BuildContext context, Widget child, FlutterChatModel inModel){
            return ;
          },
        ),
    );
  }

}