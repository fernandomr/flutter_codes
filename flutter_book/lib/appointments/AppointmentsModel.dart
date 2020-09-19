
import "../BaseModel.dart";

class Appointments {
  int id;
  String title;
  String description;
  String apptDate;
  String apptTime;

  String toString(){
    return "{ id=$id, description=$description, apptDate=$apptDate, apptTime=$apptTime }";
  }
}

class AppointmentsModel extends BaseModel{
  String apptTime;

  void setApptTime(String inApptTime){
    apptTime = inApptTime;
    notifyListeners();
  }
}

AppointmentsModel appointmentsModel = AppointmentsModel();
