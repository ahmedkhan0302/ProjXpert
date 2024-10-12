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
  String? projectName;
  List<Map<String, dynamic>> phases = [];
  bool isLoading = true; // Add a loading state

  @override
  void initState() {
    super.initState();
    checkUserTeamStatus();
    checkProjectStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: const Text('Calendar Page'),
          ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator() // Show loader if loading
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Project Name: $projectName',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: phases.length,
                      itemBuilder: (context, index) {
                        final phase = phases[index];
                        return ListTile(
                          title: Text(phase['phaseName']),
                          subtitle: Text(
                              'Start: ${phase['startDate']} \nEnd: ${phase['endDate']}'),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
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
      setState(() {
        teamID = teamId;
      });
    }
  }

  Future<void> checkProjectStatus() async {
    await checkUserTeamStatus();
    String userId = FirebaseAuth.instance.currentUser!.uid;
    if (teamID != null) {
      QuerySnapshot projectTeamSnapshot = await FirebaseFirestore.instance
          .collection('teams_projects')
          .where('teamID', isEqualTo: teamID)
          .get();

      if (projectTeamSnapshot.docs.isNotEmpty) {
        Firestoreservice firestoreService = Firestoreservice();
        for (var doc in projectTeamSnapshot.docs) {
          String projectId = doc['projectID'];
          bool isCompleted =
              await firestoreService.isProjectCompleted(projectId);
          if (!isCompleted) {
            DocumentSnapshot projSnapshot = await FirebaseFirestore.instance
                .collection('projects')
                .doc(projectId)
                .get();
            if (projSnapshot.exists) {
              setState(() {
                projectName = projSnapshot['projectName'];
                projectID = projectId;
              });
              await getBuildPhaseList(); // Fetch phases after setting projectID
            }
            setState(() {
              isLoading = false; // Stop loading
            });
            return;
          }
        }
      }
    }

    // Check if the user is a creator of a team
    QuerySnapshot projSnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .where('ownerId', isEqualTo: userId)
        .get();

    if (projSnapshot.docs.isNotEmpty) {
      Firestoreservice firestoreService = Firestoreservice();
      for (var doc in projSnapshot.docs) {
        String projectId = doc.id;
        bool isCompleted = await firestoreService.isProjectCompleted(projectId);
        if (!isCompleted) {
          setState(() {
            projectName = doc['projectName'];
            projectID = projectId;
          });
          await getBuildPhaseList(); // Fetch phases after setting projectID
          break; // Exit the loop once an incomplete project is found
        }
      }
    }

    setState(() {
      isLoading = false; // Stop loading
    });
  }

  Future<void> getBuildPhaseList() async {
    if (projectID != null) {
      Firestoreservice firestoreService = Firestoreservice();
      QuerySnapshot scheduleSnapshot =
          await firestoreService.getScheduleStream(projectID!).first;

      List<Map<String, dynamic>> fetchedPhases =
          scheduleSnapshot.docs.map((doc) {
        return {
          'phaseName': doc['phaseName'],
          'startDate': (doc['startDate'] as Timestamp).toDate(),
          'endDate': (doc['endDate'] as Timestamp).toDate(),
        };
      }).toList();

      if (mounted) {
        setState(() {
          phases = fetchedPhases;
        });
      }
    }
    setState(() {
      isLoading = true; // Start loading
    });
  }
}
