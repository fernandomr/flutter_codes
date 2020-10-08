
import "package:flutter/material.dart";
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import "package:scoped_model/scoped_model.dart";
import "TasksDBWorker.dart";
import "TasksModel.dart" show Task, TasksModel, tasksModel;

class TasksList extends StatelessWidget {

  Future _deleteTask(BuildContext context, Task task){
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext alertContext){
          return AlertDialog(
            title: Text("Delete task"),
            content: Text("Are you sure you want to delete this task?"),
            actions: [
              FlatButton(child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(alertContext).pop();
                },
              ),
              FlatButton(child: Text("Delete"),
                onPressed: () async {
                  await TasksDBWorker.db.delete(task.id);
                  Navigator.of(alertContext).pop();
                  Scaffold.of(context).showSnackBar(
                      SnackBar(
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                          content: Text("Task deleted")
                      )
                  );
                  tasksModel.loadData("notes", TasksDBWorker.db);
                },
              ),
            ],
          );
        }
    );
  }

  Widget build(BuildContext context){
    return ScopedModel<TasksModel>(model: tasksModel,
        child: ScopedModelDescendant<TasksModel>(
          builder: (BuildContext context, Widget inChild, TasksModel inModel){
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.add, color: Colors.white),
                onPressed: (){
                  tasksModel.entityBeingEdited = Task();
                  tasksModel.setStackIndex(1);
                },
              ),
              body: ListView.builder(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                itemCount: tasksModel.entityList.length,
                itemBuilder: (BuildContext context, int index) {
                  Task task = tasksModel.entityList[index];
                  String sDueDate;
                  if (task.dueDate != null){
                    List dateParts = task.dueDate.split(",");
                    DateTime dueDate = DateTime(int.parse(dateParts[0]),
                      int.parse(dateParts[1]), int.parse(dateParts[2]));
                    sDueDate = DateFormat.yMMMMd("en_US").format(dueDate.toLocal());
                  }

                  return Slidable(
                      actionExtentRatio: .25,
                      actionPane: SlidableDrawerActionPane(),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.completed == "true" ? true : false,
                          onChanged: (value) async {
                            task.completed = value.toString();
                            await TasksDBWorker.db.update(task);
                            tasksModel.loadData("tasks", TasksDBWorker.db);
                          },
                        ),
                        title: Text(
                          "${task.description}",
                            // "${task.description}",
                          style: task.completed == "true" ?
                            TextStyle(color: Theme.of(context).disabledColor,
                              decoration: TextDecoration.lineThrough
                            )
                              : TextStyle(color: Theme.of(context).textTheme.title.color)
                        ),
                        subtitle: task.dueDate == null ? null :
                          Text(
                            sDueDate,
                            style: task.completed == "true" ?
                            TextStyle(color: Theme.of(context).disabledColor,
                                decoration: TextDecoration.lineThrough
                            )
                                : TextStyle(color: Theme.of(context).textTheme.title.color),
                          ),
                        onTap: () async {
                          if (task.completed == "true") {
                            return;
                          }
                          tasksModel.entityBeingEdited = await TasksDBWorker.db.get(task.id);
                          if (tasksModel.entityBeingEdited.dueDate == null){
                            tasksModel.setChosenDate(null);
                          } else {
                            tasksModel.setChosenDate(sDueDate);
                          }
                          tasksModel.setStackIndex(1);
                        },
                      ),
                    secondaryActions: [
                      IconSlideAction(
                        caption: "Delete",
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () => _deleteTask(context, task),
                      )
                    ],
                  );
                },
              ),
            );
          },
        )
    );
  }
}