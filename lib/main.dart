import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('notesBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final box = Hive.box('notesBox');
  final TextEditingController controller = TextEditingController();

  void addNote() {
    if (controller.text.isNotEmpty) {
      box.add(controller.text);
      controller.clear();
      setState(() {});
    }
  }

  void updateNote(int index) {
    controller.text = box.getAt(index);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Update Note"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () {
              box.putAt(index, controller.text);
              controller.clear();
              Navigator.pop(context);
              setState(() {});
            },
            child: Text("Update"),
          )
        ],
      ),
    );
  }

  void deleteNote(int index) {
    box.deleteAt(index);
    setState(() {});
  }

  void showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add Note"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () {
              addNote();
              Navigator.pop(context);
            },
            child: Text("Add"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var notes = box.values.toList();

    return Scaffold(
      appBar: AppBar(title: Text("Notes App")),
      body: notes.isEmpty
          ? Center(child: Text("No Notes Yet"))
          : ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(notes[index]),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => updateNote(index),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => deleteNote(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}