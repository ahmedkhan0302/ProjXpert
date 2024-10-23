import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projxpert/pages/project_details_app.dart';
import 'package:projxpert/pages/project_view_page.dart';
import 'package:projxpert/services/firestore.dart';

class TeamDetailsPage extends StatefulWidget {
  final String? teamID;
  const TeamDetailsPage({super.key, required this.teamID});

  @override
  State<TeamDetailsPage> createState() => _TeamDetailsPageState();
}

class _TeamDetailsPageState extends State<TeamDetailsPage> {
  late Future<DocumentSnapshot> teamFuture;
  late Stream<QuerySnapshot> membersStream;
  late Stream<QuerySnapshot> projectsStream;

  @override
  void initState() {
    super.initState();
    teamFuture = Firestoreservice().getTeamById(widget.teamID);
    membersStream = Firestoreservice().getTeamMembersStream(widget.teamID);
    projectsStream = Firestoreservice().getTeamProjectsStream(widget.teamID);
  }

  void navigateToProjectDetails(String projectID) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProjectDetailsApp(projectID: projectID),
      ),
    );
  }

  void navigateToProjectViews(String projectID) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProjectViewPage(projectID: projectID),
      ),
    );
  }

  Future<void> navigateToProj(String projectID) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      DocumentSnapshot projSnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectID)
          .get();

      if (!projSnapshot.exists) {
        // Handle the case where the document does not exist
        print('Project not found');
        return;
      }

      String creatorId = projSnapshot['ownerId'];

      if (userId == creatorId) {
        navigateToProjectDetails(projectID);
      } else {
        navigateToProjectViews(projectID);
      }
    } catch (e) {
      // Handle other potential errors
      print('Error fetching project: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Padding(
          padding: EdgeInsets.only(left: 50),
          child: Text('Team Details'),
        ),
        backgroundColor: Colors.deepPurple[200],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.deepPurple[100],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<DocumentSnapshot>(
                future: teamFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading team data'));
                  } else if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text('Team not found'));
                  } else {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    return Center(
                      child: Text(
                        data['teamName'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 30),
              const Text(
                'Team Members',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: membersStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading members'));
                  } else {
                    List<DocumentSnapshot> members = snapshot.data!.docs;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: members.map((member) {
                        var data = member.data() as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            data['userName'] ?? 'Unknown Member',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
              const SizedBox(height: 30),
              const Text(
                'Projects',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: projectsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading projects'));
                  } else {
                    List<DocumentSnapshot> projects = snapshot.data!.docs;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: projects.map((project) {
                        var data = project.data() as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () => navigateToProj(project.id),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              data['projectName'] ?? 'Unknown Project',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
