import 'package:flutter/material.dart';
import 'package:week6/database.dart';
import 'package:week6/todo_item.dart';
import 'package:week6/todo_dao.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Lab – Week 8',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFB39DDB),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFB39DDB),
          elevation: 0,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFFB39DDB)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: StadiumBorder(
              side: BorderSide(color: Color(0xFFB39DDB), width: 2),
            ),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            textStyle: TextStyle(fontSize: 16),
          ),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _itemCtrl = TextEditingController();
  final _qtyCtrl  = TextEditingController();

  late AppDatabase _database;
  late TodoDao    _todoDao;
  List<TodoItem>  _items = [];

  @override
  void initState() {
    super.initState();
    _initDbAndLoad();
  }

  Future<void> _initDbAndLoad() async {
    // 1) open the database
    _database = await $FloorAppDatabase
        .databaseBuilder('app_database.db')
        .build();
    _todoDao = _database.todoDao;

    // 2) load all saved items
    final saved = await _todoDao.findAllItems();
    setState(() {
      _items = saved;
    });
  }

  @override
  void dispose() {
    _itemCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _addItem() async {
    final name = _itemCtrl.text.trim();
    final qty  = _qtyCtrl.text.trim();
    if (name.isEmpty || qty.isEmpty) return;

    // create with a unique ID
    final newItem = TodoItem(TodoItem.ID++, name, qty);

    // persist to DB
    await _todoDao.insertItem(newItem);

    // update UI
    setState(() {
      _items.add(newItem);
      _itemCtrl.clear();
      _qtyCtrl.clear();
    });
  }

  Future<void> _confirmDelete(int index) async {
    final toDelete = _items[index];
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete this item?'),
        content: Text('Remove "${toDelete.name}" from the list?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('No')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),  child: Text('Yes')),
        ],
      ),
    );

    if (ok == true) {
      await _todoDao.deleteItem(toDelete);
      setState(() => _items.removeAt(index));
    }
  }

  Widget listPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _itemCtrl,
                  decoration: InputDecoration(hintText: 'Type the item here'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: 'Type the quantity here'),
                ),
              ),
              SizedBox(width: 12),
              ElevatedButton(onPressed: _addItem, child: Text('Add Item')),
            ],
          ),
          SizedBox(height: 32),
          Expanded(
            child: _items.isEmpty
                ? Center(child: Text('There are no items in the list'))
                : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (ctx, i) {
                final item = _items[i];
                return GestureDetector(
                  onLongPress: () => _confirmDelete(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Center(
                      child: Text(
                        '${i + 1}: ${item.name}  quantity: ${item.qty}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Week 8 – Floor Lab')),
      body: listPage(),
    );
  }
}
