
import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "TasksDBWorker.dart";
import "TasksModel.dart" show TasksModel, tasksModel;
import '../utils.dart' as utils;

class TasksEntry extends StatelessWidget{

  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _contentEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TasksEntry(){
    _titleEditingController.addListener(() {
      tasksModel.entityBeingEdited.title = _titleEditingController.text;
    });

    _contentEditingController.addListener(() {
      tasksModel.entityBeingEdited.content = _contentEditingController.text;
    });
  }

  void _save(BuildContext context, TasksModel pNote) async{

    if (!_formKey.currentState.validate()){
      return;
    }

    if (pNote.entityBeingEdited.id == null){
      await TasksDBWorker.db.create(tasksModel.entityBeingEdited);
    } else {
      await TasksDBWorker.db.update(tasksModel.entityBeingEdited);
    }

    tasksModel.loadData("notes", TasksDBWorker.db);

    pNote.setStackIndex(0);

    Scaffold.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.green, duration: Duration(seconds: 2), content: Text("Note saved"))
    );
  }

  Widget build(BuildContext context){
    _titleEditingController.text = tasksModel.entityBeingEdited.title;
    _contentEditingController.text = tasksModel.entityBeingEdited.content;

    return ScopedModel(
        model: tasksModel,
        child: ScopedModelDescendant<TasksModel>(
          builder: (BuildContext context, Widget child, TasksModel note) {
            return Scaffold(
              body: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    ListTile(
                      leading: Icon(Icons.title),
                      title: TextFormField(
                        decoration: InputDecoration(hintText: "Title"),
                        controller: _titleEditingController,
                        validator: (String value){
                          if (value.length == 0){
                            return "Please enter a title";
                          }
                          return null;
                        },
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.today),
                      title: Text("Due date"),
                      subtitle: Text(
                        tasksModel.chosenDate == null ? "" : tasksModel.chosenDate
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit), color: Colors.blue,
                        onPressed: () async{
                          String chosenDate = await utils.selectDate(
                            context, tasksModel, tasksModel.entityBeingEdited.dueDate
                          );
                          if (chosenDate != null){
                            tasksModel.entityBeingEdited.dueDate = chosenDate;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: Padding(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                child: Row(
                  children: [
                    FlatButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          note.setStackIndex(0);
                        }
                    ),
                    Spacer(),
                    FlatButton(
                        child: Text("Save"),
                        onPressed: () {
                          _save(context, tasksModel);
                        }
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }
}