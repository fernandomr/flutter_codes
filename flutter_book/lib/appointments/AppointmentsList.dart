
import "package:flutter/material.dart";
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import "package:scoped_model/scoped_model.dart";
import "AppointmentsDBWorker.dart";
import "AppointmentsModel.dart" show Appointments, AppointmentsModel, appointmentsModel;

class AppointmentsList extends StatelessWidget {

  Future _deleteTask(BuildContext context, Appointments task){
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
                  await AppointmentsDBWorker.db.delete(task.id);
                  Navigator.of(alertContext).pop();
                  Scaffold.of(context).showSnackBar(
                      SnackBar(
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                          content: Text("Appointments deleted")
                      )
                  );
                  appointmentsModel.loadData("notes", AppointmentsDBWorker.db);
                },
              ),
            ],
          );
        }
    );
  }

  Widget build(BuildContext context){
    return ScopedModel<AppointmentsModel>(model: appointmentsModel,
        child: ScopedModelDescendant<AppointmentsModel>(
          builder: (BuildContext context, Widget inChild, AppointmentsModel inModel){
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.add, color: Colors.white),
                onPressed: (){
                  appointmentsModel.entityBeingEdited = Appointments();
                  appointmentsModel.setStackIndex(1);
                },
              ),
              body: ListView.builder(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                itemCount: appointmentsModel.entityList.length,
                itemBuilder: (BuildContext context, int index) {
                  Appointments task = appointmentsModel.entityList[index];
                  String sDueDate;
                  if (task.dueDate != null){
                    List dateParts = task.dueDate.split(",");
                    DateTime dueDate = DateTime(int.parse(dateParts[0]),
                        int.parse(dateParts[1]), int.parse(dateParts[2]));
                    sDueDate = DateFormat.yMMMMd("en_US").format(dueDate.toLocal());
                  }

                  return Slidable(
                    actionExtentRatio: .25,
                    actionPane: null,
                    child: ListTile(
                      leading: Checkbox(
                        value: task.completed == "true" ? true : false,
                        onChanged: (value) async {
                          task.completed = value.toString();
                          await AppointmentsDBWorker.db.update(task);
                          appointmentsModel.loadData("tasks", AppointmentsDBWorker.db);
                        },
                      ),
                      title: Text(
                          "${task.description}",
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
                        appointmentsModel.entityBeingEdited = await AppointmentsDBWorker.db.get(task.id);
                        if (appointmentsModel.entityBeingEdited.dueDate == null){
                          appointmentsModel.setChosenDate(null);
                        } else {
                          appointmentsModel.setChosenDate(sDueDate);
                        }
                        appointmentsModel.setStackIndex(1);
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