
import "../BaseModel.dart";

class Note {
	int id;
	String title;
	String content;
	String color;

	String toString(){
		return "{ id=$id, title=$title, content=$content, color=$color }";
	}
}

class NotesModel extends BaseModel{
	String color;

	void setColor(String pColor){
		color = pColor;
		notifyListeners();
	}
}

NotesModel notesModel = NotesModel();
