import 'dart:convert';

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: SizedBox(height: 50, width: 50,
                child: CircularProgressIndicator(
                  value: null, strokeWidth: 10,
                ),
              )),
              Container(margin: EdgeInsets.only(top: 20),
                child: Center(child:
                  Text("Please wait, contacting server...",
                      style: new TextStyle(color: Colors.white)
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }
  );
}

void hidePleaseWait(){
  Navigator.of(model.rootBuildContext).pop();
}

void connectToServer(final BuildContext pMainBuildContext, final Function inCallback){
  _io = SocketIOManager().createSocketIO(
    serverURL, "/", query: "",
    socketStatusCallback: (inData) {
      if (inData == "connect"){
        _io.subscribe("newUser", newUser);
        _io.subscribe("created", created);
        _io.subscribe("closed", closed);
        _io.subscribe("joined", joined);
        _io.subscribe("left", left);
        _io.subscribe("kicked", kicked);
        _io.subscribe("invited", invited);
        _io.subscribe("posted", posted);
        inCallback();
      }
    }
  );
  _io.init();
  _io.connect();
}

void validate(final String inUserName, final String inPassword, final Function inCallback){
  showPleaseWait();
  _io.sendMessage(
      "validate",
      "{\"userName\" : \"$inUserName\", \"password\" : \"$inPassword\" }",
      (inData) {
        Map<String, dynamic> response = jsonDecode(inData);
        hidePleaseWait();
        inCallback(response["status"]);
      }
  );
}

void listRooms(final Function inCallback){
  showPleaseWait();
  _io.sendMessage("listRooms", "{}", (inData) {
    Map<String, dynamic> response = jsonDecode(inData);
    hidePleaseWait();
    inCallback(response);
  });
}

void create(final String pRoomName, final String pRoomDescriptor, final int pMaxNumber,
  final bool pIsPrivate, final pUserName, final Function pCallBack){

}

void join(final String pRoomName, final String pUserName, final Function pCallBack){

}

void leave(final String pRoomName, final String pUserName, final Function pCallBack){

}

void listUsers(final Function pCallBack){

}

void invite(final String pRoomName, final String pUserName, final String pInvitingUser, final Function pCallBack){

}

void post(final String pRoomName, final String pUserName, final String pMessage, final Function pCallBack){

}

void close(final String pRoomName, final Function pCallBack){

}

void kick(final String pRoomName, final String pUserName, final Function pCallBack){

}

void newUser(inData){
  Map<String, dynamic> payload = jsonDecode(inData);
  model.setUserList(payload);
}

void created(inData){
  Map<String, dynamic> payload = jsonDecode(inData);
  model.setRoomList(payload);
}

void closed(inData){
  Map<String, dynamic> payload = jsonDecode(inData);
  model.setRoomList(payload);

  if(payload["roomName"] == model.currentRoomName){
    model.removeRoomInvite(payload["roomName"]);
    model.setCurrentRoomUserList({});
    model.setCurrentRoom(FlutterChatModel.DEFAULT_ROOM_NAME);
    model.setCurrentRoomEnabled(false);
    model.setGreetings("The room was closed by its creator");
    Navigator.of(model.rootBuildContext).pushNamedAndRemoveUntil("/", ModalRoute.withName("/"));
  }
}

void joined(inData){
  Map<String, dynamic> payload = jsonDecode(inData);
  if (model.currentRoomName == payload["roomName"]){
    model.setCurrentRoomUserList(payload["users"]);
  }
}

void left(inData){
  Map<String, dynamic> payload = jsonDecode(inData);
  if (model.currentRoomName == payload["roomName"]){
    model.setCurrentRoomUserList(payload["users"]);
  }
}

void kicked(inData){
  Map<String, dynamic> payload = jsonDecode(inData);
  model.setRoomList(payload);

  if(payload["roomName"] == model.currentRoomName){
    model.removeRoomInvite(payload["roomName"]);
    model.setCurrentRoomUserList({});
    model.setCurrentRoom(FlutterChatModel.DEFAULT_ROOM_NAME);
    model.setCurrentRoomEnabled(false);
    model.setGreetings("You've been removed from the room");
    Navigator.of(model.rootBuildContext).pushNamedAndRemoveUntil("/", ModalRoute.withName("/"));
  }
}

void invited(inData) async {
  Map<String, dynamic> payload = jsonDecode(inData);
  String roomName = payload["roomName"];
  String inviterName = payload["inviterName"];
  model.addRoomInvite(roomName);
  Scaffold.of(model.rootBuildContext).showSnackBar(
    SnackBar(
      backgroundColor: Colors.amber,
      duration: Duration(seconds: 60),
      content: Text("You've been invited to the room '$roomName' by user '$inviterName',\n\n "
          "You can enter the room from the lobby"),
      action: SnackBarAction(label: "Ok", onPressed: () {},),
    ),
  );
}

void posted(inData){
  Map<String, dynamic> payload = jsonDecode(inData);
  if (model.currentRoomName == payload["roomName"]){
    model.addMessage(payload["userName"], payload["message"]);
  }
}
