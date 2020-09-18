import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'appointments/Appointments.dart';
import 'contacts/Contacts.dart';
import 'notes/Notes.dart';
import 'tasks/Tasks.dart';
import 'utils.dart' as utils;

void main() {
  runApp(FlutterBook());
}

class FlutterBook extends StatelessWidget {

  startMeUp() async{
    Directory docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;
  }

  Widget build(BuildContext context){
    startMeUp();
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text("FlutterBook"),
            bottom: TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.date_range),
                  text: "Appointments",
                ),
                Tab(
                  icon: Icon(Icons.contacts),
                  text: "Contacts",
                ),
                Tab(
                  icon: Icon(Icons.note),
                  text: "Notes",
                ),
                Tab(
                  icon: Icon(Icons.assignment_turned_in),
                  text: "Tasks",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
