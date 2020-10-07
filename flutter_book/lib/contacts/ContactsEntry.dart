
import 'dart:io';
import 'package:path/path.dart';
import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';
import "package:scoped_model/scoped_model.dart";
import 'ContactsDBWorker.dart';
import "ContactsModel.dart" show ContactsModel, contactsModel;
import '../utils.dart' as utils;

class ContactsEntry extends StatelessWidget{

  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TasksEntry(){
    _nameEditingController.addListener(() {
      contactsModel.entityBeingEdited.name = _nameEditingController.text;
    });

    _phoneEditingController.addListener(() {
      contactsModel.entityBeingEdited.phone = _phoneEditingController.text;
    });

    _emailEditingController.addListener(() {
      contactsModel.entityBeingEdited.email = _emailEditingController.text;
    });
  }

  void _save(BuildContext context, ContactsModel pContact) async{

    if (!_formKey.currentState.validate()){
      return;
    }

    var id = pContact.entityBeingEdited.id;
    if (pContact.entityBeingEdited.id == null){
      id = await ContactsDBWorker.db.create(contactsModel.entityBeingEdited);
    } else {
      await ContactsDBWorker.db.update(contactsModel.entityBeingEdited);
    }

    File avatarFile = File(join(utils.docsDir.path, id.toString()));
    if (avatarFile.existsSync()){
      avatarFile.renameSync(join(utils.docsDir.path, id.toString()));
    }

    contactsModel.loadData("contacts", ContactsDBWorker.db);

    pContact.setStackIndex(0);

    Scaffold.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.green, duration: Duration(seconds: 2), content: Text("Contact saved"))
    );
  }

  Future _selectAvatar(BuildContext context){
    return showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  child: Text("Take a picture"),
                  onTap: () async{
                    var imagePicker = new ImagePicker();
                    // var cameraImage = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
                    var cameraImage = await imagePicker.getImage(source: ImageSource.camera);
                    if (cameraImage != null){
                      //cameraImage.copySync(join(utils.docsDir.path, "avatar"));
                      File tmpFile = File(cameraImage.path);
                      if (tmpFile.existsSync()){
                        tmpFile.renameSync(join(utils.docsDir.path, "avatar"));
                      }
                      contactsModel.triggerRebuild();
                    }
                    Navigator.of(context).pop();
                  },
                ),
                GestureDetector(
                  child: Text("Sellect from gallery"),
                  onTap: () async{
                    var imagePicker = new ImagePicker();
                    var galleryImage = await imagePicker.getImage(source: ImageSource.gallery);
                    if (galleryImage != null){
                      // galleryImage.copySync(join(utils.docsDir.path, "avatar"));
                      File tmpFile = File(galleryImage.path);
                      if (tmpFile.existsSync()){
                        tmpFile.renameSync(join(utils.docsDir.path, "avatar"));
                      }
                      contactsModel.triggerRebuild();
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget build(BuildContext context){
    _nameEditingController.text = contactsModel.entityBeingEdited.name;
    _phoneEditingController.text = contactsModel.entityBeingEdited.phone;
    _emailEditingController.text = contactsModel.entityBeingEdited.email;

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