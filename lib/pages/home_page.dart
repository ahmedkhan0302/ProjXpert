import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String generateRandomCode() {
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();
  return String.fromCharCodes(
    Iterable.generate(
      6,
      (_) => characters.codeUnitAt(random.nextInt(characters.length)),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController teamNameController = TextEditingController();
  final TextEditingController teamCodeController = TextEditingController();
  final TextEditingController projectNameController = TextEditingController();
  String? teamName;
  String? teamCode;
  String? projectName;
  String? teamID;
  String? projectID;

  @override
  void initState() {
    super.initState();
    checkUserTeamStatus();
    checkProjectStatus();
  }

  Future<void> checkUserTeamStatus() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Check if the user is a creator of a team
    QuerySnapshot teamSnapshot = await FirebaseFirestore.instance
        .collection('teams')
        .where('creatorId', isEqualTo: userId)
        .get();

    if (teamSnapshot.docs.isNotEmpty) {
      setState(() {
        teamName = teamSnapshot.docs.first['teamName'];
        teamCode = teamSnapshot.docs.first['teamCode'];
        teamID = teamSnapshot.docs.first.id;
      });
      return;
    }

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
        teamName = teamDoc['teamName'];
        teamCode = teamDoc['teamCode'];
      });
    }
  }

  Future<void> checkProjectStatus() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Check if the user is a creator of a team
    QuerySnapshot projSnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .where('ownerId', isEqualTo: userId)
        .get();

    if (projSnapshot.docs.isNotEmpty) {
      setState(() {
        projectName = projSnapshot.docs.first['projectName'];
      });
      return;
    }

    // Check if the user is in the user_team collection
    QuerySnapshot projTeamSnapshot = await FirebaseFirestore.instance
        .collection('teams_projects')
        .where('teamID', isEqualTo: teamID)
        .get();

    if (projTeamSnapshot.docs.isNotEmpty) {
      setState(() {
        projectName = projTeamSnapshot.docs.first['projectName'];
        projectID = projTeamSnapshot.docs.first.id;
      });
    }
  }

  void createTeam() async {
    String teamName = teamNameController.text;
    String teamCode = generateRandomCode();
    String userId = FirebaseAuth.instance.currentUser!.uid;

    DocumentReference teamRef =
        await FirebaseFirestore.instance.collection('teams').add({
      'teamName': teamName,
      'teamCode': teamCode,
      'creatorId': userId,
    });

    await FirebaseFirestore.instance.collection('user_teams').add({
      'userId': userId,
      'teamId': teamRef.id,
    });

    setState(() {
      this.teamName = teamName;
      this.teamCode = teamCode;
    });

    if (mounted) {
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  void createProject() async {
    projectName = projectNameController.text;
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Check if the user is in a team
    if (teamID != null) {
      DocumentSnapshot teamDoc = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamID)
          .get();

      // Allow project creation only if the user is the creator of the team
      if (teamDoc['creatorId'] != userId) {
        showErrorMessage("Only the team creator can create a project.");
        setState(() {
          projectName = null;
        });
        return;
      }
    }

    DocumentReference projectRef =
        await FirebaseFirestore.instance.collection('projects').add({
      'projectName': projectName,
      'ownerId': userId,
    });

    // If the user is in a team, add the project to the team's projects
    if (teamID != null) {
      await FirebaseFirestore.instance.collection('teams_projects').add({
        'teamID': teamID,
        'projectID': projectRef.id,
      });
    }

    setState(() {
      projectName = projectName;
      projectID = projectRef.id;
    });

    if (mounted) {
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  void joinTeam() async {
    String teamCode = teamCodeController.text;
    String userId = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot teamSnapshot = await FirebaseFirestore.instance
        .collection('teams')
        .where('teamCode', isEqualTo: teamCode)
        .get();

    if (teamSnapshot.docs.isNotEmpty) {
      String teamId = teamSnapshot.docs.first.id;

      await FirebaseFirestore.instance.collection('user_teams').add({
        'userId': userId,
        'teamId': teamId,
      });

      setState(() {
        teamName = teamSnapshot.docs.first['teamName'];
        this.teamCode = teamCode;
      });

      if (mounted) {
        Navigator.of(context).pop(); // Close the dialog
      }
    } else {
      // Show error message
      showErrorMessage("Invalid team code");
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.indigoAccent,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  void leaveTeam() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Find the user_team document
    QuerySnapshot userTeamSnapshot = await FirebaseFirestore.instance
        .collection('user_teams')
        .where('userId', isEqualTo: userId)
        .where('teamId', isEqualTo: teamID)
        .get();

    if (userTeamSnapshot.docs.isNotEmpty) {
      // Delete the user_team document
      await FirebaseFirestore.instance
          .collection('user_teams')
          .doc(userTeamSnapshot.docs.first.id)
          .delete();
    }

    setState(() {
      teamName = null;
      teamCode = null;
      teamID = null;
    });
  }

  void deleteProject() async {
    // setState(() {
    //   projectName = null;
    // });
    if (projectID == null) {
      showErrorMessage("No project selected");
      return;
    }

    // Delete the project from the projects collection
    await FirebaseFirestore.instance
        .collection('projects')
        .doc(projectID)
        .delete();

    // Delete the project from the teams_projects collection
    QuerySnapshot teamProjSnapshot = await FirebaseFirestore.instance
        .collection('teams_projects')
        .where('projectID', isEqualTo: projectID)
        .get();

    for (var doc in teamProjSnapshot.docs) {
      await FirebaseFirestore.instance
          .collection('teams_projects')
          .doc(doc.id)
          .delete();
    }

    setState(() {
      projectName = null;
      projectID = null;
    });

    if (mounted) {
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 32.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final containerWidth = constraints.maxWidth * 0.9;
            return Align(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: containerWidth,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        if (teamName != null && teamCode != null) ...[
                          Text('Team Name: $teamName'),
                          const SizedBox(height: 8.0),
                          Text('Team Code: $teamCode'),
                          const SizedBox(height: 8.0),
                          ElevatedButton(
                            onPressed: leaveTeam,
                            child: const Text('Leave Team'),
                          ),
                        ] else ...[
                          const Text('Team'),
                          const SizedBox(height: 8.0),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Create Team'),
                                    content: TextField(
                                      controller: teamNameController,
                                      decoration: const InputDecoration(
                                          hintText: 'Enter team name'),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: createTeam,
                                        child: const Text('Create'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Text('Create'),
                          ),
                          const SizedBox(height: 8.0),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Join Team'),
                                    content: TextField(
                                      controller: teamCodeController,
                                      decoration: const InputDecoration(
                                          hintText: 'Enter team code'),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: joinTeam,
                                        child: const Text('Join'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Text('Join'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                    width: containerWidth,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(children: [
                      if (projectName != null) ...[
                        Text('Project Name: $projectName'),
                        const SizedBox(height: 8.0),
                        ElevatedButton(
                          onPressed: deleteProject,
                          child: const Text('Delete Project'),
                        ),
                      ] else ...[
                        const Text('Project'),
                        const SizedBox(height: 8.0),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Create Project'),
                                  content: TextField(
                                    controller: projectNameController,
                                    decoration: const InputDecoration(
                                        hintText: 'Enter project name'),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: createProject,
                                      child: const Text('Create'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text('Add Project'),
                        ),
                      ],
                    ]),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
