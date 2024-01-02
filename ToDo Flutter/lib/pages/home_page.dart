import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/database.dart';
import '../util/dialog_box.dart';
import '../util/todo_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // reference the hive box
  final _myBox = Hive.box('mybox');
  // List<ToDoDataBase> _foundToDo = [];
  ToDoDataBase db = ToDoDataBase();

  @override
  void initState() {
    // _foundToDo = _myBox;
    // if this is the 1st time ever openin the app, then create default data
    if (_myBox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      // there already exists data
      db.loadData();
    }

    super.initState();
  }

  // text controller
  final _controller = TextEditingController();

  // checkbox was tapped
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
    });
    db.updateDataBase();
  }

  // save new task
  void saveNewTask() {
    String newTask = _controller.text.trim();

    if (newTask.isNotEmpty) {
      setState(() {
        db.toDoList.add([newTask, false]);
        _controller.clear();
      });
      Navigator.of(context).pop();
      db.updateDataBase();
    }
  }

  //void _runFilter(String enteredKeyword) {
  //List<ToDoDataBase> results = [];
  //if (enteredKeyword.isEmpty) {
  //results = _myBox;
  //} else {
  //results = _myBox
  //.where((item) => item.todoText!
  //.toLowerCase()
  //.contains(enteredKeyword.toLowerCase()))
  //.toList();
  //}

  //setState(() {
  //_foundToDo = results;
  //});
  //}

  // create a new task
  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          onSave: saveNewTask,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  // delete task
  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDataBase();
  }

  Icon cusIcon = const Icon(Icons.search);
  Widget cusSearchBar = const Text("ToDo App");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 249),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 245, 245, 249),
        elevation: 0,
        centerTitle: true,
        title: cusSearchBar,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                if (cusIcon.icon == Icons.search) {
                  cusIcon = const Icon(Icons.cancel);
                  cusSearchBar = TextField(
                    textInputAction: TextInputAction.go,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search here",
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                  );
                } else {
                  cusIcon = const Icon(Icons.search);
                  cusSearchBar = const Text("ToDo App");
                }
              });
            },
            icon: cusIcon,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF5F52EE),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: db.toDoList.length,
            itemBuilder: (context, index) {
              return ToDoTile(
                taskName: db.toDoList[index][0],
                taskCompleted: db.toDoList[index][1],
                onChanged: (value) => checkBoxChanged(value, index),
                deleteFunction: (context) => deleteTask(index),
              );
            },
          ),
        ],
      ),
    );
  }
}

