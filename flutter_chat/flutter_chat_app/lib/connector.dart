import 'package:flutter/material.dart';
import 'package:flutter_chat_app/flutterChatModel.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

String serverURL = "http://192.168.1.2";
SocketIO _io;

void showPleaseWait(){
  showDialog(
    context: model.rootBuildContext,
    barrierDismissible: false,
    builder: (BuildContext context){
      return Dialog(
        child: Container(width: 150, height: 150,
          alignment: AlignmentDirectional.center,
          decoration: BoxDecoration(color: Colors.blue[200]),
        ),
      );
    }
  );
}