
import "package:flutter/material.dart";
import 'package:flutter_book/tasks/TasksDBWorker.dart';
import "package:scoped_model/scoped_model.dart";
import "TasksList.dart";
import "TasksEntry.dart";
import "TasksModel.dart" show TasksModel, tasksModel;

class Tasks extends StatelessWidget{

  Tasks(){
    tasksModel.loadData("tasks", TasksDBWorker.db);
  }

  Widget build(BuildContext context){

    return ScopedModel<TasksModel>(
        model: tasksModel,
        child: ScopedModelDescendant<TasksModel>(
          builder: (BuildContext context, Widget child, TasksModel inModel){
            return IndexedStack(
              index: inModel.stackIndex,
              children: [TasksList(), TasksEntry()],
            );
          },
        ));
  }
}