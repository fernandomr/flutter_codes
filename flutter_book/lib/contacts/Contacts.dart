
import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import 'package:flutter_book/contacts/ContactsDBWorker.dart';
import 'package:flutter_book/contacts/ContactsModel.dart' show ContactsModel, contactsModel;
import "ContactsList.dart";
import "ContactsEntry.dart";

class Contacts extends StatelessWidget{

  Contacts(){
    contactsModel.loadData("contacts", ContactsDBWorker.db);
  }

  Widget build(BuildContext context){

    return ScopedModel<ContactsModel>(
        model: contactsModel,
        child: ScopedModelDescendant<ContactsModel>(
          builder: (BuildContext context, Widget child, ContactsModel inModel){
            return IndexedStack(
              index: inModel.stackIndex,
              children: [ContactsList(), ContactsEntry()],
            );
          },
        ));
  }
}