
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class BaseModel extends Model {

  BuildContext rootBuildContext;
  Directory docsDir;
  String greeting = "";
  String userName = "";
  static final String DEFAULT_ROOM_NAME = "Not currently in a room";
  String currentRoomName = DEFAULT_ROOM_NAME;
  List currentRoomUserList = [];
  bool currentRoomEnabled = false;
  List currentRoomMessages = [];
  List roomList = [];
  List userList = [];
  bool creatorFunctionsEnabled = false;
  Map roomInvites = {};

  void setGreetings(final String inGreeting){
    greeting = inGreeting;
    notifyListeners();
  }

  void setUserName(final String pUserName){
    userName = pUserName;
    notifyListeners();
  }

  void setCurrentRoom(final String pCurrentRoom){
    currentRoomName = pCurrentRoom;
    notifyListeners();
  }

  void setCreatorFunctionsEnabled(final bool pCreatorFunction){
    creatorFunctionsEnabled = pCreatorFunction;
    notifyListeners();
  }

  void setCurrentRoomEnabled(final bool pCurrentRoomEnabled){
    currentRoomEnabled = pCurrentRoomEnabled;
    notifyListeners();
  }

  void addMessage(final String pUserName, final String pMessage){
    currentRoomMessages.add({
      "userName": pUserName,
      "message": pMessage
    });
    notifyListeners();
  }

  void setRoomList(final Map pRoomList){
    List rooms = [];

    for (String roomName in pRoomList.keys){
      Map room = pRoomList[roomName];
      rooms.add(room);
    }
    roomList = rooms;
    notifyListeners();
  }

}