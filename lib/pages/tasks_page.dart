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

  // final List<Task> tasks = [
  //   Task(name: 'Complete the project'),
  //   Task(name: 'Review the code'),
  //   Task(name: 'Submit the report'),
  // ];

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
                    },
                    child: const Text("Add"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: openTaskDialog,
        backgroundColor: Colors.deepPurple[300],
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: firestoreservice.getTaskStream(userid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List tasksList = snapshot.data!.docs;

              return ListView.builder(
                  itemCount: tasksList.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = tasksList[index];
                    //String docID = doc.id;

                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;
                    String taskName = data['task'];
                    bool isCompleted = data['done'];

                    Task task = Task(name: taskName, isCompleted: isCompleted);

                    return TaskTile(
                      task: task,
                      onChanged: (bool? value) {
                        setState(() {
                          task.isCompleted = value ?? false;
                        });
                        // firestoreservice.updateTask(docID, task);
                      },
                    );
                  });
            } else {
              return const Text("No data");
            }
          }),
    );
  }
}

class Task {
  Task({required this.name, this.isCompleted = false});

  final String name;
  bool isCompleted;
}

class TaskTile extends StatefulWidget {
  const TaskTile({super.key, required this.task, required this.onChanged});

  final Task task;
  final ValueChanged<bool?> onChanged;

  @override
  _TaskTileState createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
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
        title: Text(widget.task.name),
        trailing: Checkbox(
          value: widget.task.isCompleted,
          onChanged: (bool? value) {
            setState(() {
              widget.task.isCompleted = value ?? false;
            });
            widget.onChanged(value);
          },
        ),
      ),
    );
  }
}
