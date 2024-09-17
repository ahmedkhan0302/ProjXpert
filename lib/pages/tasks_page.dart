import 'package:flutter/material.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final List<Task> tasks = [
    Task(name: 'Complete the project'),
    Task(name: 'Review the code'),
    Task(name: 'Submit the report'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks Page'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return TaskTile(
            task: tasks[index],
            onChanged: (bool? value) {
              setState(() {
                tasks[index].isCompleted = value ?? false;
              });
            },
          );
        },
      ),
    );
  }
}

class Task {
  Task({required this.name, this.isCompleted = false});

  final String name;
  bool isCompleted;
}

class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task, required this.onChanged});

  final Task task;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.name),
      trailing: Checkbox(
        value: task.isCompleted,
        onChanged: onChanged,
      ),
    );
  }
}
