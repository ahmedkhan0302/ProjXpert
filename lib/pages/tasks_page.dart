import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projxpert/services/firestore.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TextEditingController textController = TextEditingController();
  final Firestoreservice firestoreservice = Firestoreservice();
  final user = FirebaseAuth.instance.currentUser;
  final userid = FirebaseAuth.instance.currentUser?.uid;
  List<Task> incompleteTasks = [];
  List<Task> completeTasks = [];

  void openTaskDialog({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: "Enter Task"),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                if (docID == null && user != null) {
                  firestoreservice.addTask(textController.text, user!.uid);
                }
                textController.clear();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task cannot be empty')),
                );
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openTaskDialog,
        backgroundColor: Colors.deepPurple[300],
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userid != null ? firestoreservice.getTaskStream(userid!) : null,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var tasks = snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return Task(
              id: doc.id,
              name: data['task'],
              isCompleted: data['done'],
            );
          }).toList();

          incompleteTasks = tasks.where((task) => !task.isCompleted).toList();
          completeTasks = tasks.where((task) => task.isCompleted).toList();

          return ReorderableListView(
            children: [
              ...incompleteTasks.map((task) => Dismissible(
                    key: ValueKey(task.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      if (userid != null) {
                        firestoreservice.deleteTask(userid!, task.id);
                        setState(() {
                          incompleteTasks.remove(task);
                        });
                      }
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: TaskTile(
                      task: task,
                      onChanged: (bool? value) {
                        setState(() {
                          task.isCompleted = value ?? false;
                        });
                        if (userid != null) {
                          firestoreservice.updateTaskStatus(
                              userid!, task.id, task.isCompleted);
                        }
                      },
                    ),
                  )),
              ...completeTasks.map((task) => Dismissible(
                    key: ValueKey(task.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      if (userid != null) {
                        firestoreservice.deleteTask(userid!, task.id);
                        setState(() {
                          completeTasks.remove(task);
                        });
                      }
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: TaskTile(
                      task: task,
                      onChanged: (bool? value) {
                        setState(() {
                          task.isCompleted = value ?? false;
                        });
                        if (userid != null) {
                          firestoreservice.updateTaskStatus(
                              userid!, task.id, task.isCompleted);
                        }
                      },
                    ),
                  )),
            ],
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final Task movedTask = incompleteTasks.removeAt(oldIndex);
                incompleteTasks.insert(newIndex, movedTask);
                // Update Firestore with new order if necessary
                // firestoreservice.updateTaskOrder(userid, incompleteTasks);
              });
            },
          );
        },
      ),
    );
  }
}

class Task {
  Task({required this.id, required this.name, required this.isCompleted});

  final String id;
  final String name;
  bool isCompleted;
}

class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task, required this.onChanged});

  final Task task;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 5.0)
        ],
      ),
      child: ListTile(
        title: Text(task.name),
        trailing: Checkbox(
          value: task.isCompleted,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
