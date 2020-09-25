
import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "AppointmentsDBWorker.dart";
import "AppointmentsModel.dart" show AppointmentsModel, appointmentsModel;
import '../utils.dart' as utils;

class AppointmentsEntry extends StatelessWidget{

  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _contentEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TasksEntry(){
    _titleEditingController.addListener(() {
      appointmentsModel.entityBeingEdited.title = _titleEditingController.text;
    });

    _contentEditingController.addListener(() {
      appointmentsModel.entityBeingEdited.content = _contentEditingController.text;
    });
  }

  void _save(BuildContext context, AppointmentsModel pNote) async{

    if (!_formKey.currentState.validate()){
      return;
    }

    if (pNote.entityBeingEdited.id == null){
      await AppointmentsDBWorker.db.create(appointmentsModel.entityBeingEdited);
    } else {
      await AppointmentsDBWorker.db.update(appointmentsModel.entityBeingEdited);
    }

    appointmentsModel.loadData("notes", AppointmentsDBWorker.db);

    pNote.setStackIndex(0);

    Scaffold.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.green, duration: Duration(seconds: 2), content: Text("Note saved"))
    );
  }

  Future _selectTime(BuildContext context) async{
    TimeOfDay initialTime = TimeOfDay.now();

    if (appointmentsModel.entityBeingEdited.apptTime != null){
      List timeParts = appointmentsModel.entityBeingEdited.apptTime.split(",");
      initialTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1])
      );
    }

    TimeOfDay picked = await showTimePicker(context: context, initialTime: initialTime);

    if (picked != null){
      appointmentsModel.entityBeingEdited.apptTime = "${picked.hour},${picked.minute}";
      appointmentsModel.setApptTime(picked.format(context));
    }
  }

  Widget build(BuildContext context){
    _titleEditingController.text = appointmentsModel.entityBeingEdited.title;
    _contentEditingController.text = appointmentsModel.entityBeingEdited.content;

    return ScopedModel(
        model: appointmentsModel,
        child: ScopedModelDescendant<AppointmentsModel>(
          builder: (BuildContext context, Widget child, AppointmentsModel note) {
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
                          appointmentsModel.chosenDate == null ? "" : appointmentsModel.chosenDate
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit), color: Colors.blue,
                        onPressed: () async{
                          String chosenDate = await utils.selectDate(
                              context, appointmentsModel, appointmentsModel.entityBeingEdited.dueDate
                          );
                          if (chosenDate != null){
                            appointmentsModel.entityBeingEdited.dueDate = chosenDate;
                          }
                        },
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.alarm),
                      title: Text("Time"),
                      subtitle: Text(appointmentsModel.apptTime == null ? "" : appointmentsModel.apptTime),
                      trailing: IconButton(
                        icon:  Icon(Icons.edit),
                        color: Colors.blue,
                        onPressed: () => _selectTime(context),
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
                          _save(context, appointmentsModel);
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