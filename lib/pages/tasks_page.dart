import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  final userid = FirebaseAuth.instance.currentUser!.uid;
  List<Task> incompleteTasks = [];
  List<Task> completeTasks = [];

  @override
  void initState() {
    super.initState();
    buildTaskLists();
  }

  Future<void> buildTaskLists() async {
    QuerySnapshot taskSnapshot =
        await firestoreservice.getTaskStream(userid).first;
    List<Task> fetchedIncompleteTasks = [];
    List<Task> fetchedCompleteTasks = [];

    for (var doc in taskSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String taskId = doc.id;
      String taskName = data['task'];
      bool isCompleted = data['done'];

      Task task = Task(id: taskId, name: taskName, isCompleted: isCompleted);

      if (isCompleted) {
        fetchedCompleteTasks.add(task);
      } else {
        fetchedIncompleteTasks.add(task);
      }
    }

    if (mounted) {
      setState(() {
        incompleteTasks = fetchedIncompleteTasks;
        completeTasks = fetchedCompleteTasks;
      });
    }
  }

  void openTaskDialog({String? docID}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
              ),
              actions: [
                //button to save
                ElevatedButton(
                    onPressed: () {
                      if (docID == null) {
                        firestoreservice.addTask(
                            textController.text, user!.uid);
                      }
                      textController.clear();
                      Navigator.pop(context);
                      buildTaskLists(); // Refresh the task lists
                    },
                    child: const Text("Add"))
              ],
            ));
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
      body: ListView.builder(
        itemCount: incompleteTasks.length + completeTasks.length,
        itemBuilder: (context, index) {
          if (index < incompleteTasks.length) {
            Task task = incompleteTasks[index];
            return TaskTile(
              task: task,
              onChanged: (bool? value) {
                setState(() {
                  task.isCompleted = value ?? false;
                });
                firestoreservice.updateTaskStatus(
                    userid, task.id, task.isCompleted);
                buildTaskLists(); // Refresh the task lists
              },
            );
          } else {
            Task task = completeTasks[index - incompleteTasks.length];
            return TaskTile(
              task: task,
              onChanged: (bool? value) {
                setState(() {
                  task.isCompleted = value ?? false;
                });
                firestoreservice.updateTaskStatus(
                    userid, task.id, task.isCompleted);
                buildTaskLists(); // Refresh the task lists
              },
            );
          }
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
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8.0),
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
