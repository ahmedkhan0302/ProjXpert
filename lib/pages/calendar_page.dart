import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projxpert/services/firestore.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  String? teamID;
  String? projectID;
  List<Map<String, dynamic>> phases = [];

  @override
  void initState() {
    super.initState();
    checkUserTeamStatus();
    checkProjectStatus();
    if (projectID != null) {
      Firestoreservice().getScheduleStream(projectID!).listen((snapshot) {
        setState(() {
          phases = snapshot.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return {
              "phase": data['phaseName'] ?? 'Unknown Phase',
              "start": data['startDate'] != null
                  ? data['startDate'].toDate().toString()
                  : 'No Start Date',
              "end": data['endDate'] != null
                  ? data['endDate'].toDate().toString()
                  : 'No End Date',
            };
          }).toList();
        });
      });
    }
  }

  Future<void> checkUserTeamStatus() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Check if the user is in the user_team collection
    QuerySnapshot userTeamSnapshot = await FirebaseFirestore.instance
        .collection('user_teams')
        .where('userId', isEqualTo: userId)
        .get();

    if (userTeamSnapshot.docs.isNotEmpty) {
      String teamId = userTeamSnapshot.docs.first['teamId'];
      DocumentSnapshot teamDoc = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .get();

      setState(() {
        teamID = teamId;
      });
    }
  }

  Future<void> checkProjectStatus() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    if (teamID != null) {
      QuerySnapshot projectTeamSnapshot = await FirebaseFirestore.instance
          .collection('teams_projects')
          .where('teamID', isEqualTo: teamID)
          .get();

      if (projectTeamSnapshot.docs.isNotEmpty) {
        String projectId = projectTeamSnapshot.docs.first['projectID'];
        DocumentSnapshot projSnapshot = await FirebaseFirestore.instance
            .collection('projects')
            .doc(projectId)
            .get();
        setState(() {
          projectID = projectId;
        });
        return;
      }
    }

    // Check if the user is a creator of a team
    QuerySnapshot projSnapshot = await FirebaseFirestore.instance
        .collection('current_projects')
        .where('ownerId', isEqualTo: userId)
        .get();

    if (projSnapshot.docs.isNotEmpty) {
      setState(() {
        projectID = projSnapshot.docs.first.id;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: projectID == null
            ? const Center(
                child: Text(
                  'No Project Found',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('projects')
                    .doc(projectID)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(
                      child: Text(
                        'Project not found',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  var projectData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        projectData['projectName'] ?? 'Unknown Project',
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Project Schedule',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Display each phase in the list or show 'No Phases Found'
                      // phases.isEmpty
                      //     ? const Center(
                      //         child: Text(
                      //           'No Phases Found',
                      //           style: TextStyle(
                      //             color: Colors.red,
                      //             fontSize: 20,
                      //             fontWeight: FontWeight.bold,
                      //           ),
                      //         ),
                      //       )
                      Column(
                        children: phases.map((phase) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  phase['phase']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text('Start Date: ${phase['start']}'),
                                Text('End Date: ${phase['end']}'),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      // Input fields to add a new phase
                    ],
                  );
                },
              ),
      ),
    );
  }
}
