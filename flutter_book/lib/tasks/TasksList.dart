
import "package:flutter/material.dart";
import 'package:flutter_slidable/flutter_slidable.dart';
import "package:scoped_model/scoped_model.dart";
import "TasksDBWorker.dart";
import "TasksModel.dart" show Task, TasksModel, tasksModel;

class NotesList extends StatelessWidget {

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
                  tasksModel.setColor(null);
                  tasksModel.setStackIndex(1);
                },
              ),
              body: ListView.builder(
                itemCount: tasksModel.entityList.length,
                itemBuilder: (BuildContext context, int index) {
                  Task note = tasksModel.entityList[index];
                  Color color = Colors.white;
                  switch(note.color){
                    case "red" : color = Colors.red; break;
                    case "green" : color = Colors.green; break;
                    case "blue" : color = Colors.blue; break;
                    case "yellow" : color = Colors.yellow; break;
                    case "grey" : color = Colors.grey; break;
                    case "purple" : color = Colors.purple; break;
                  }

                  return Container(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Slidable(
                      // delegate: SlidableDrawerDelegate,
                      actionExtentRatio: .25,
                      secondaryActions: [
                        IconSlideAction(
                          caption: "Delete",
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () => _deleteTask(context, note),
                        )
                      ],
                      child: Card(
                        elevation: 8,
                        color: color,
                        child: ListTile(
                          title: Text("${note.title}"),
                          subtitle: Text("${note.content}"),
                          onTap: () async {
                            tasksModel.entityBeingEdited = await NotesDbWorker.db.get(note.id);
                            tasksModel.setColor(tasksModel.entityBeingEdited.color);
                            tasksModel.setStackIndex(1);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        )
    );
  }
}