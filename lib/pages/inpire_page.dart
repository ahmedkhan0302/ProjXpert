import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projxpert/pages/project_details_app.dart';
import 'package:projxpert/pages/project_view_page.dart';
import 'package:projxpert/services/firestore.dart';

class InspirePage extends StatefulWidget {
  const InspirePage({super.key});

  @override
  _InspirePageState createState() => _InspirePageState();
}

class _InspirePageState extends State<InspirePage> {
  final Firestoreservice firestoreservice = Firestoreservice();

  final TextEditingController _searchController = TextEditingController();

  List projects = [];
  List filteredProjects = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _fetchProjects();
  // }

  void _filterProjects(String query) {
    List filteredProjx = [];
    for (var project in projects) {
      Map<String, dynamic> data = project.data() as Map<String, dynamic>;
      String projectName = data['projectName'];
      if (projectName.toLowerCase().contains(query.toLowerCase())) {
        filteredProjx.add(project);
      }
    }

    if (!mounted) return; // Ensure the widget is still mounted

    setState(() {
      filteredProjects = filteredProjx;
    });
  }

  void navigateToProjectDetails(projectID) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProjectDetailsApp(projectID: projectID),
      ),
    );
  }

  void navigateToProjectViews(projectID) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProjectViewPage(projectID: projectID),
      ),
    );
  }

  Future<void> navigateToProj(projectID) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot projSnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .doc(projectID)
        .get();

    String creatorId = projSnapshot['ownerId'];

    if (userId == creatorId) {
      navigateToProjectDetails(projectID);
    } else {
      navigateToProjectViews(projectID);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: const Text('Inspire'),
          ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Projects',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: _filterProjects,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: firestoreservice.getProjStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      projects = snapshot.data!.docs;

                      if (filteredProjects.isEmpty) {
                        filteredProjects = projects;
                      }

                      return ListView.builder(
                          itemCount: filteredProjects.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot doc = filteredProjects[index];
                            //String docID = doc.id;

                            Map<String, dynamic> data =
                                doc.data() as Map<String, dynamic>;
                            String pName = data['projectName'];

                            return GestureDetector(
                              onTap: () => navigateToProj(doc.id),
                              child: ProjectTile(
                                projectName: pName,
                              ),
                            );
                          });
                    } else {
                      return const Text("No data");
                    }
                  }),
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
