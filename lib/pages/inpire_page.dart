import 'package:flutter/material.dart';

class InspirePage extends StatelessWidget {
  const InspirePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspire Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search Projects',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: const [
                  ProjectTile(projectName: 'Project 1'),
                  ProjectTile(projectName: 'Project 2'),
                  ProjectTile(projectName: 'Project 3'),
                  ProjectTile(projectName: 'Project 4'),
                  ProjectTile(projectName: 'Project 5'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectTile extends StatelessWidget {
  final String projectName;

  const ProjectTile({required this.projectName, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(projectName),
      ),
    );
  }
}
