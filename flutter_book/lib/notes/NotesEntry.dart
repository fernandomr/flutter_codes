
import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "NotesDBWorker.dart";
import "NotesModel.dart" show NotesModel, notesModel;

class NotesEntry extends StatelessWidget{

  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _contentEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  NotesEntry(){
    _titleEditingController.addListener(() {
      notesModel.entityBeingEdited.title = _titleEditingController.text;
    });
    
    _contentEditingController.addListener(() {
      notesModel.entityBeingEdited.content = _contentEditingController.text;
    });
  }

  Widget build(BuildContext context){
    _titleEditingController.text = notesModel.entityBeingEdited.title;
    _contentEditingController.text = notesModel.entityBeingEdited.content;
    
    return ScopedModel(
        model: notesModel,
        child: ScopedModelDescendant<NotesModel>(
          builder: (BuildContext context, Widget child, NotesModel note) {
            return Scaffold(
              bottomNavigationBar: Padding(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                child: Row(
                  children: [
                    FlatButton(
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          note.setStackIndex(0);
                        },
                        child: Text("Cancel")),
                    Spacer(),
                    FlatButton(
                        onPressed: () {
                          _save(context, notesModel);
                        },
                        child: Text("Save"))
                    )
                  ],
                ),
              ),
            );
          },
        ));
  }
}