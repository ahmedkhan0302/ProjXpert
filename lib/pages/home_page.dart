import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projxpert/pages/team_details_page.dart';
import 'package:projxpert/pages/project_details_app.dart';
import 'package:projxpert/services/firestore.dart';

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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkUserTeamStatus();
    checkProjectStatus();
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
        teamName = teamDoc['teamName'];
        teamCode = teamDoc['teamCode'];
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

          break; // Exit the loop once an incomplete project is found
        }
      }
    }

    setState(() {
      isLoading = false; // Stop loading
    });
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
      teamID = teamRef.id;
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Only Team creator can create a project.')),
        );
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
      'isCompleted': false,
      'synopsis': 'Synopsis of the $projectName',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // await FirebaseFirestore.instance
    //     .collection('current_projects')
    //     .doc(projectRef.id)
    //     .set({
    //   'projectName': projectName,
    //   'ownerId': userId,
    // });

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

      QuerySnapshot projsnapshot = await FirebaseFirestore.instance
          .collection('teams_projects')
          .where('teamID', isEqualTo: teamId)
          .get();

      if (projsnapshot.docs.isNotEmpty) {
        Firestoreservice firestoreService = Firestoreservice();
        for (var doc in projsnapshot.docs) {
          String projectId = doc['projectID'];
          bool isCompleted =
              await firestoreService.isProjectCompleted(projectId);
          if (!isCompleted) {
            DocumentSnapshot projSnapshot = await FirebaseFirestore.instance
                .collection('projects')
                .doc(projectId)
                .get();

            setState(() {
              teamName = teamSnapshot.docs.first['teamName'];
              this.teamCode = teamCode;
              teamID = teamId;
              projectID = projectId;
              projectName = projSnapshot['projectName'];
            });
            break; // Exit the loop once an incomplete project is found
          }
        }
      } else {
        setState(() {
          teamName = teamSnapshot.docs.first['teamName'];
          this.teamCode = teamCode;
          teamID = teamId;
        });
      }

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

    // make project name and id null as well if the project belongs to the team and he is not the creator
    QuerySnapshot projTeamSnapshot = await FirebaseFirestore.instance
        .collection('teams_projects')
        .where('teamID', isEqualTo: teamID)
        .get();

    if (projTeamSnapshot.docs.isNotEmpty) {
      DocumentSnapshot projDoc = await FirebaseFirestore.instance
          .collection('projects')
          .doc(projTeamSnapshot.docs.first.id)
          .get();
      if (projDoc.exists) {
        if (projDoc["ownerID"] != userId) {
          setState(() {
            projectName = null;
            projectID = null;
          });
        }
      }
    }
    setState(() {
      teamName = null;
      teamCode = null;
      teamID = null;
    });
  }

  void deleteProject() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    if (projectID == null) {
      showErrorMessage("No project selected");
      return;
    }
    if (teamID != null) {
      DocumentSnapshot teamDoc = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamID)
          .get();

      // Allow project creation only if the user is the creator of the team
      if (teamDoc['creatorId'] != userId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Only Team creator can delete a project.')),
        );
        return;
      }
    }
    // Delete the project from the teams_projects collection
    await FirebaseFirestore.instance
        .collection('projects')
        .doc(projectID)
        .update({'isCompleted': true});

    setState(() {
      projectName = null;
      projectID = null;
    });
  }

  void navigateToProjectDetails() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProjectDetailsApp(projectID: projectID),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final containerWidth = constraints.maxWidth * 0.9;
                  return Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTeamSection(containerWidth),
                        const SizedBox(height: 16.0),
                        _buildProjectSection(containerWidth),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildTeamSection(double containerWidth) {
    return GestureDetector(
      onTap: () {
        // Navigate to the Team Details page
        if (teamName != null && teamCode != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamDetailsPage(
                teamID: teamID,
              ),
            ),
          );
        }
      },
      child: Container(
        width: containerWidth,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            if (teamName != null && teamCode != null) ...[
              Text(
                'Team Name: $teamName',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple, // Set color to purple
                ),
              ),
              const SizedBox(height: 8.0),
              Text('Team Code: $teamCode',
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: leaveTeam,
                child: const Text('Leave Team'),
              ),
            ] else ...[
              const Text('Team', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              _buildTeamButton(
                  'Create',
                  () => _showTeamDialog(
                      'Create Team', teamNameController, createTeam)),
              const SizedBox(height: 8.0),
              _buildTeamButton(
                  'Join',
                  () => _showTeamDialog(
                      'Join Team', teamCodeController, joinTeam)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTeamButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            Colors.blueAccent, // Changed from primary to backgroundColor
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(label),
    );
  }

  void _showTeamDialog(
      String title, TextEditingController controller, VoidCallback onPressed) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration:
                const InputDecoration(hintText: 'Enter team name or code'),
          ),
          actions: [
            TextButton(
              onPressed: onPressed,
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProjectSection(double containerWidth) {
    return GestureDetector(
      onTap: projectName != null ? navigateToProjectDetails : null,
      child: Container(
        width: containerWidth,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            if (projectName != null) ...[
              Text(
                'Project Name: $projectName',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple, // Set color to purple
                ),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: deleteProject,
                child: const Text('End Project'),
              ),
            ] else ...[
              const Text('Project',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              _buildTeamButton('Add Project', () => _showProjectDialog()),
            ],
          ],
        ),
      ),
    );
  }

  void _showProjectDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Project'),
          content: TextField(
            controller: projectNameController,
            decoration: const InputDecoration(hintText: 'Enter project name'),
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
  }
}
