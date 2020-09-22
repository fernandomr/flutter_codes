
import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import 'package:flutter_book/appointments/AppointmentsDBWorker.dart';
import 'package:flutter_book/appointments/AppointmentsModel.dart' show AppointmentsModel, appointmentsModel;
import "AppointmentsList.dart";
import "AppointmentsEntry.dart";

class Appointments extends StatelessWidget{

  Appointments(){
    appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);
  }

  Widget build(BuildContext context){

    return ScopedModel<AppointmentsModel>(
        model: appointmentsModel,
        child: ScopedModelDescendant<AppointmentsModel>(
          builder: (BuildContext context, Widget child, AppointmentsModel inModel){
            return IndexedStack(
              index: inModel.stackIndex,
              children: [AppointmentsList(), AppointmentsEntry()],
            );
          },
        ));
  }
}