
import "package:flutter/material.dart";
import 'dart:io';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../utils.dart' as utils;
import "package:scoped_model/scoped_model.dart";
import "ContactsDBWorker.dart";
import "ContactsModel.dart" show Contact, ContactsModel, contactsModel;

class ContactsList extends StatelessWidget {

  Future _delete(BuildContext context, Contact pContact) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext alertContext){
          return AlertDialog(
            title: Text("Delete contact"),
            content: Text("Are you sure you want to delete this contact?"),
            actions: [
              FlatButton(child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(alertContext).pop();
                },
              ),
              FlatButton(child: Text("Delete"),
                onPressed: () async {
                  File avatarFile = File(join(utils.docsDir.path, pContact.id.toString()));
                  if (avatarFile.existsSync()) {
                    avatarFile.deleteSync();
                  }
                  await ContactsDBWorker.db.delete(pContact.id);
                  Navigator.of(alertContext).pop();
                  Scaffold.of(context).showSnackBar(
                      SnackBar(
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                          content: Text("Contact deleted")
                      )
                  );
                  contactsModel.loadData("contacts", ContactsDBWorker.db);
                },
              ),
            ],
          );
        }
    );
  }

  void _edit(BuildContext context, Contact pContact) async{
    contactsModel.entityBeingEdited = await ContactsDBWorker.db.get(pContact.id);
    if (contactsModel.entityBeingEdited == null){
      contactsModel.setChosenDate(null);
    } else {
      List dateParts = contactsModel.entityBeingEdited.apptDate.split(",");
      DateTime apptDate = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2])
      );
      contactsModel.setChosenDate(DateFormat.yMMMMd("en_US").format(apptDate.toLocal()));
      if (contactsModel.entityBeingEdited.apptTime == null){
        contactsModel.setApptTime(null);
      } else {
        List timeParts =contactsModel.entityBeingEdited.apptTime.split(",");
        TimeOfDay apptTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1])
        );
        contactsModel.setApptTime(apptTime.format(context));
      }

      contactsModel.setStackIndex(1);
      Navigator.pop(context);
    }
  }

  void _show(DateTime date, BuildContext context) async{
    showModalBottomSheet(context: context,
        builder: (BuildContext context){
          return ScopedModel<ContactsModel>(
              model: contactsModel,
              child: ScopedModelDescendant<ContactsModel>(
                builder: (BuildContext context, Widget child, ContactsModel model){
                  return Scaffold(
                    body: Container(child: Padding(padding: EdgeInsets.all(10),
                      child: GestureDetector(
                        child: Column(
                          children: [
                            Text(DateFormat.yMMMMd("en_US").format(date.toLocal()),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Theme.of(context).accentColor, fontSize : 24),
                            ),
                            Divider(),
                            Expanded(
                                child: ListView.builder(
                                    itemCount: contactsModel.entityList.length,
                                    itemBuilder: (BuildContext context, int index){
                                      Contact appointment = contactsModel.entityList[index];
                                      if (appointment.apptDate !="${date.year},${date.month},${date.day}"){
                                        return Container(height : 0);
                                      }
                                      String apptTime = "";
                                      if (appointment.apptTime != null){
                                        List timeParts = appointment.apptTime.split(",");
                                        TimeOfDay at = TimeOfDay(
                                            hour : int.parse(timeParts[0]),
                                            minute : int.parse(timeParts[1]));
                                        apptTime = " (${at.format(context)})";
                                      }

                                      return Slidable(
                                        // delegate : SlidableDrawerDelegate()
                                        actionExtentRatio: .25,
                                        child: Container(
                                          margin: EdgeInsets.only(bottom : 8),
                                          color : Colors.grey.shade300,
                                          child: ListTile(
                                            title : Text("${appointment.title}$apptTime"),
                                            subtitle : appointment.description == null ? null : Text("${appointment.description}"),
                                            onTap: () async{
                                              _edit(context, appointment);
                                            },
                                          ),
                                        ),
                                        secondaryActions: [
                                          IconSlideAction(
                                              caption: "Delete", color: Colors.red,
                                              icon: Icons.delete,
                                              onTap: () => _delete(context, appointment)
                                          )
                                        ],
                                      );
                                    }
                                )
                            ),
                          ],
                        ),
                      ),
                    ),
                    ),
                  );
                },
              ));
        }
    );
  }

  Widget build(BuildContext context){
    EventList<Event> _markedDateMap = EventList();

    for(int i = 0; i < contactsModel.entityList.length; i++){
      Contact appointment = ContactsModel().entityList[i];
      List dateParts = appointment.apptDate.split(",");
      DateTime apptDate = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]),int.parse(dateParts[2]));
      _markedDateMap.add(apptDate, Event(date: apptDate,
          icon: Container(decoration: BoxDecoration(color: Colors.blue))
      ));
    }

    return ScopedModel<ContactsModel>(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder: (context, child, model){
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child : Icon(Icons.add, color : Colors.white),
              onPressed: () async{
                File avatarFile = File(join(utils.docsDir.path, "avatar"));
                if (avatarFile.existsSync()){
                  avatarFile.deleteSync();
                }
                contactsModel.entityBeingEdited = Contact();
                DateTime now = DateTime.now();
                contactsModel.setChosenDate(null);
                contactsModel.setStackIndex(1);
              },
            ),
            body: ListView.builder(
              itemCount: contactsModel.entityList.length,
              itemBuilder: (BuildContext context, int index){
                Contact contact = contactsModel.entityList[index];
                File avatarFile = File(join(utils.docsDir.path, contact.id.toString()));
                bool avatarFileExists = avatarFile.existsSync();
                return Column(
                  children: [
                    Slidable(
                      // delegate : SlidableDrawerDelegate(),
                      actionExtentRatio: .25,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigoAccent,
                          foregroundColor: Colors.white,
                          backgroundImage: avatarFileExists ? FileImage(avatarFile) : null,
                          child: avatarFileExists ? null : Text(contact.name.substring(0, 1).toUpperCase()),
                        ),
                        title: Text("${contact.name}"),
                        subtitle: contact.phone == null ? null : Text("${contact.phone}"),
                        onTap: () async{
                          File avatarFile = File(join(utils.docsDir.path, "avatar"));
                          if (avatarFile.existsSync()){
                            avatarFile.deleteSync();
                          }
                          contactsModel.entityBeingEdited = await ContactsDBWorker.db.get(contact.id);
                          if (contactsModel.entityBeingEdited.birthday == null){
                            contactsModel.setChosenDate(null);
                          } else {
                            List dateParts = contactsModel.entityBeingEdited.birthday.split(',');
                            DateTime birthday = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));
                            contactsModel.setChosenDate(DateFormat.yMMMMd("en_US").format(birthday.toLocal()));
                          }
                          contactsModel.setStackIndex(1);
                        },

                      ),
                      secondaryActions: [
                        IconSlideAction(caption: "Delete", color: Colors.red,
                          icon: Icons.delete,
                          onTap: () => _delete(context, contact),
                        ),
                      ],
                    ),
                    Divider(),
                  ],
                );
              }
            ),
          );
        },
      ),
    );
  }
}