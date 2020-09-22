
import "package:flutter/material.dart";
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import "package:scoped_model/scoped_model.dart";
import "AppointmentsDBWorker.dart";
import "AppointmentsModel.dart" show Appointments, AppointmentsModel, appointmentsModel;

class AppointmentsList extends StatelessWidget {

  Future _deleteAppointment(BuildContext context, Appointments task){
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
    EventList<Event> _markedDateMap = EventList();

    for(int i = 0; i < appointmentsModel.entityList.length; i++){
      Appointments appointment = AppointmentsModel().entityList[i];
      List dateParts = appointment.apptDate.split(",");
      DateTime apptDate = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]),int.parse(dateParts[2]));
      _markedDateMap.add(apptDate, Event(date: apptDate,
        icon: Container(decoration: BoxDecoration(color: Colors.blue))
      ));
    }
  }
}