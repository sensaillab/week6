import 'package:floor/floor.dart';

@entity
class TodoItem {
  @primaryKey
  final int id;
  static int ID = 1;

  final String name;
  final String qty;


  TodoItem(this.id, this.name, this.qty) {
    if (id >= ID) {
      ID = id + 1;
    }
  }
}
