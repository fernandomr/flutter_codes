
import 'dart:html';
import 'dart:io';
import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';
import "package:scoped_model/scoped_model.dart";
import "ContactsDBWorker.dart";
import "ContactsModel.dart" show ContactsModel, contactsModel;
import '../utils.dart' as utils;

class ContactsEntry extends StatelessWidget{

  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _contentEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TasksEntry(){
    _titleEditingController.addListener(() {
      contactsModel.entityBeingEdited.title = _titleEditingController.text;
    });

    _contentEditingController.addListener(() {
      contactsModel.entityBeingEdited.content = _contentEditingController.text;
    });
  }

  void _save(BuildContext context, ContactsModel pContact) async{

    if (!_formKey.currentState.validate()){
      return;
    }

    if (pContact.entityBeingEdited.id == null){
      await ContactsDBWorker.db.create(contactsModel.entityBeingEdited);
    } else {
      await ContactsDBWorker.db.update(contactsModel.entityBeingEdited);
    }

    contactsModel.loadData("notes", ContactsDBWorker.db);

    pContact.setStackIndex(0);

    Scaffold.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.green, duration: Duration(seconds: 2), content: Text("Contact saved"))
    );
  }

  Future _selectTime(BuildContext context) async{
    TimeOfDay initialTime = TimeOfDay.now();

    if (contactsModel.entityBeingEdited.apptTime != null){
      List timeParts = contactsModel.entityBeingEdited.apptTime.split(",");
      initialTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1])
      );
    }

    TimeOfDay picked = await showTimePicker(context: context, initialTime: initialTime);

    if (picked != null){
      contactsModel.entityBeingEdited.apptTime = "${picked.hour},${picked.minute}";
      contactsModel.setApptTime(picked.format(context));
    }
  }

  Future _selectAvatar(BuildContext context){
    return showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(child: Text("Take a picture"),
                  onTap: () async{
                    var cameraImage = await ImagePicker.platform.pickImage(source: ImageSource.camera);
                    if (cameraImage != null){
                      cameraImage.copySync(join(utils.docsDir.path, "avatar"));
                      contactsModel.triggerRebuild();
                    }
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ),
        );
      }
    );
  }

  Widget build(BuildContext context){
    _titleEditingController.text = contactsModel.entityBeingEdited.title;
    _contentEditingController.text = contactsModel.entityBeingEdited.content;

    return ScopedModel(
        model: contactsModel,
        child: ScopedModelDescendant<ContactsModel>(
          builder: (BuildContext context, Widget child, ContactsModel contact) {
            File avatarFile = File(join(utils.docsDir.path, "avatar"));
            if (avatarFile.existsSync() == false) {
              if (contact.entityBeingEdited != null && contact.entityBeingEdited.id != null){
                avatarFile = File(join(utils.docsDir.path, contact.entityBeingEdited.id.toString()));
              }
            }
            return Scaffold(
              bottomNavigationBar: Padding(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                child: Row(
                  children: [
                    FlatButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          File avatarFile = File(join(utils.docsDir.path, "avatar"));
                          if (avatarFile.existsSync()){
                            avatarFile.deleteSync();
                          }
                          FocusScope.of(context).requestFocus(FocusNode());
                          contact.setStackIndex(0);
                        }
                    ),
                    Spacer(),
                    FlatButton(
                        child: Text("Save"),
                        onPressed: () {
                          _save(context, contactsModel);
                        }
                    ),
                  ],
                ),
              ),
              body: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    ListTile(
                      title: avatarFile.existsSync() ? Image.file(avatarFile) : Text("No avatar image for this contact"),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        color: Colors.blue,
                        onPressed: () => _selectAvatar(context),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.person),
                      title: TextFormField(
                        decoration: InputDecoration(hintText: "Name"),
                        controller: _nameEditingController,
                        validator: (String value){
                          if (value.length == 0){
                            return "Please enter a name";
                          }
                          return null;
                        },
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.phone),
                      title: TextFormField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(hintText: "Phone"),
                        controller: _phoneEditingController,
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.email),
                      title: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(hintText: "Email"),
                        controller: _emailEditingController,
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.today),
                      title: Text("Birthday"),
                      subtitle: Text(contactsModel.chosenDate == null ? "" : contactsModel.chosenDate),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        color: Colors.blue,
                        onPressed: () async{
                          String chosenDate = await utils.selectDate(
                              context, contactsModel, contactsModel.entityBeingEdited.birthday);
                          if (chosenDate != null){
                            contactsModel.entityBeingEdited.birthday = chosenDate;
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),

            );
          },
        ));
  }
}