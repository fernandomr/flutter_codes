
import "package:flutter/material.dart";
import 'package:flutter_book/notes/NotesModel.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import "package:scoped_model/scoped_model.dart";
import "NotesDBWorker.dart";
import "NotesModel.dart" show Note, NotesModel, notesModel;

class NotesList extends StatelessWidget {

  Future _deleteNote(BuildContext context, Note note){
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext alertContext){
        return AlertDialog(
          title: Text("Delete note"),
          content: Text("Are you sure you want to delete this note?"),
          actions: [
            FlatButton(child: Text("Cancel"),
              onPressed: () {
                Navigator.of(alertContext).pop();
              },
            ),
            FlatButton(child: Text("Delete"),
              onPressed: () async {
                await NotesDbWorker.db.delete(note.id);
                Navigator.of(alertContext).pop();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                      content: Text("Note deleted")
                  )
                );
                notesModel.loadData("notes", NotesDbWorker.db);
              },
            ),
          ],
        );
      }
    );
  }

  Widget build(BuildContext context){
    return ScopedModel<NotesModel>(model: notesModel,
        child: ScopedModelDescendant<NotesModel>(
          builder: (BuildContext context, Widget inChild, NotesModel inModel){
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.add, color: Colors.white),
                onPressed: (){
                  notesModel.entityBeingEdited = Note();
                  notesModel.setColor(null);
                  notesModel.setStackIndex(1);
                },
              ),
              body: ListView.builder(
                itemCount: notesModel.entityList.length,
                itemBuilder: (BuildContext context, int index) {
                  Note note = notesModel.entityList[index];
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
                      actionPane: SlidableDrawerActionPane(),
                      secondaryActions: [
                        IconSlideAction(
                          caption: "Delete",
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () => _deleteNote(context, note),
                        )
                      ],
                      child: Card(
                        elevation: 8,
                        color: color,
                        child: ListTile(
                          title: Text("${note.title}"),
                          subtitle: Text("${note.content}"),
                          onTap: () async {
                            notesModel.entityBeingEdited = await NotesDbWorker.db.get(note.id);
                            notesModel.setColor(notesModel.entityBeingEdited.color);
                            notesModel.setStackIndex(1);
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