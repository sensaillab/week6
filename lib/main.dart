import 'package:flutter/material.dart';
import 'database.dart';
import 'todo_item.dart';
import 'todo_dao.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Lab – Week 9',
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
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 🎁 Easter egg state
  int _titleTapCount = 0;

  final _itemCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();

  late AppDatabase _database;
  late TodoDao _todoDao;
  List<TodoItem> _items = [];
  TodoItem? selectedItem;

  @override
  void initState() {
    super.initState();
    selectedItem = null;
    _initDbAndLoad();
  }

  Future<void> _initDbAndLoad() async {
    _database = await $FloorAppDatabase
        .databaseBuilder('app_database.db')
        .build();
    _todoDao = _database.todoDao;
    final saved = await _todoDao.findAllItems();
    setState(() => _items = saved);
  }

  Future<void> _addItem() async {
    final name = _itemCtrl.text.trim();
    final qty = _qtyCtrl.text.trim();
    if (name.isEmpty || qty.isEmpty) return;

    final newItem = TodoItem(TodoItem.ID++, name, qty);
    await _todoDao.insertItem(newItem);
    setState(() {
      _items.add(newItem);
      _itemCtrl.clear();
      _qtyCtrl.clear();
    });
  }

  Future<void> _deleteSelected() async {
    if (selectedItem != null) {
      await _todoDao.deleteItem(selectedItem!);
      setState(() {
        _items.removeWhere((i) => i.id == selectedItem!.id);
        selectedItem = null;
      });
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
                  onTap: () => setState(() => selectedItem = item),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Center(
                      child: Text(
                        '${i + 1}: ${item.name} (qty: ${item.qty})',
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

  Widget detailsPage() {
    if (selectedItem == null) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ID: ${selectedItem!.id}', style: TextStyle(fontSize: 18)),
          Text('Name: ${selectedItem!.name}', style: TextStyle(fontSize: 18)),
          Text('Qty: ${selectedItem!.qty}', style: TextStyle(fontSize: 18)),
          SizedBox(height: 24),
          Row(
            children: [
              ElevatedButton(
                onPressed: _deleteSelected,
                child: Text('Delete'),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => setState(() => selectedItem = null),
                child: Text('Close'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget reactiveLayout() {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    if (width > height && width > 720) {
      return Row(
        children: [
          Expanded(flex: 1, child: listPage()),
          VerticalDivider(width: 1),
          Expanded(flex: 2, child: detailsPage()),
        ],
      );
    } else {
      return selectedItem == null ? listPage() : detailsPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            _titleTapCount++;
            if (_titleTapCount == 7) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('🐰 You found the Easter Egg! 🥚')),
              );
              _titleTapCount = 0;
            }
          },
          child: Text('Flutter Week 9 – Responsive Lab'),
        ),
      ),
      body: reactiveLayout(),
    );
  }

  @override
  void dispose() {
    _itemCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }
}
