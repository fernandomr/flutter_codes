
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