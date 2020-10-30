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
            return AlertDialog(
              content: Container(
                height: 220,
                child: Form(
                  key: _loginFormKey,
                  child: Column(
                      children: [
                        Text(
                          "Enter a username and password to register with the server",
                          textAlign: TextAlign.center,
                          // TODO fontSize: 18,
                          style: TextStyle(
                              color: Theme.of(model.rootBuildContext).accentColor
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          validator: (String value){
                            if (value.length == 0 || value.length > 10){
                              return "Please enter a username between 1 and 10 characters";
                            }
                            return null;
                          },
                          onSaved: (String value){
                            _userName = value;
                          },
                          decoration: InputDecoration(
                            hintText: "Username",
                            labelText: "Username"
                          ),
                        ),
                        TextFormField(
                          obscureText: true,
                          validator: (String value){
                            if (value.length == 0){
                              return "Please enter a password";
                            }
                            return null;
                          },
                          onSaved: (String value){
                            _password = value;
                          },
                          decoration: InputDecoration(
                              hintText: "Password",
                              labelText: "Password"
                          ),
                        ),
                      ]
                  ),
                )
              )
            );
          },
        ),
    );
  }

}