import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this for hyperlink functionality
import 'package:projxpert/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectDetailsApp extends StatefulWidget {
  final String? projectID;
  const ProjectDetailsApp({super.key, required this.projectID});

  String? getprojID() => projectID;

  @override
  State<ProjectDetailsApp> createState() => _ProjectDetailsAppState();
}

class _ProjectDetailsAppState extends State<ProjectDetailsApp> {
  // int _selectedIndex = 3;

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }

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
          child: Text('P r o j X p e r t'),
        ),
        backgroundColor: Colors.deepPurple[200],
      ),
      body: SingleChildScrollView(
        // Wrap body in SingleChildScrollView
        padding: const EdgeInsets.all(30.0),

        child: Container(
          decoration: BoxDecoration(
            color: Colors.deepPurple[100],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<DocumentSnapshot>(
                future: Firestoreservice().getProjectById(widget.projectID!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text('Error loading project data'));
                  } else if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text('Project not found'));
                  } else {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    return Center(
                      child: Text(
                        data['projectName'],
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
              // Add the Project Synopsis Widget here
              ProjectSynopsisWidget(projectID: widget.projectID!),
              const SizedBox(height: 30),
              TechToolsWidget(projectID: widget.projectID!),
              const SizedBox(height: 30),
              DocumentDropdown(projectID: widget.projectID!),
              const SizedBox(height: 30),
              ProjectScheduleWidget(projectID: widget.projectID!),
              const SizedBox(height: 20),
              ProjectStatusWidget(
                  projectID: widget.projectID!), // Example of usage
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class ProjectSynopsisWidget extends StatefulWidget {
  final String projectID;
  const ProjectSynopsisWidget({super.key, required this.projectID});

  @override
  _ProjectSynopsisWidgetState createState() => _ProjectSynopsisWidgetState();
}

class _ProjectSynopsisWidgetState extends State<ProjectSynopsisWidget> {
  String synopsis = '';

  @override
  void initState() {
    super.initState();
    Firestoreservice().getProjectSynopsis(widget.projectID).then((value) {
      setState(() {
        synopsis = value;
      });
    });
  }

  Future<void> _updateSynopsis(String newSynopsis) async {
    await Firestoreservice().editProjectSynopsis(widget.projectID, newSynopsis);
    setState(() {
      synopsis = newSynopsis;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Project Synopsis',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          const SizedBox(height: 15),
          Text(
            synopsis,
            textAlign: TextAlign.left,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Container(
            alignment: Alignment.centerRight, // Aligns the button to the right
            child: ElevatedButton(
              onPressed: _showEditDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5), // Smaller padding
                textStyle: const TextStyle(fontSize: 12), // Smaller font size
              ),
              child: const Text(
                'Edit', // Text displayed on the button
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showEditDialog() {
    final TextEditingController controller =
        TextEditingController(text: synopsis);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Synopsis'),
          content: TextField(
            controller: controller,
            maxLines: 5, // Allow multiple lines for the synopsis
            decoration: const InputDecoration(hintText: 'Enter new synopsis'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateSynopsis(controller.text.trim());
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class TechToolsWidget extends StatefulWidget {
  final String? projectID;
  const TechToolsWidget({super.key, required this.projectID});

  @override
  _TechToolsWidgetState createState() => _TechToolsWidgetState();
}

class _TechToolsWidgetState extends State<TechToolsWidget> {
  List<String> tools = []; // Move tools to state

  @override
  void initState() {
    super.initState();
    if (widget.projectID != null) {
      Firestoreservice().getTechTools(widget.projectID!).then((fetchedTools) {
        setState(() {
          tools = fetchedTools;
        });
      });
    }
  }

  void _showAddToolDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a New Tool'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter tool name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newTool = controller.text.trim();
                if (newTool.isNotEmpty) {
                  Firestoreservice()
                      .addTechTool(widget.projectID!, newTool)
                      .then((_) {
                    setState(() {
                      tools.add(newTool); // Add new tool to the list
                    });
                  });
                }
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.97, // Set width to 97% of the screen width
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Tech Tools Used',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
          ),
          const SizedBox(height: 20),
          _buildToolList(),
          const SizedBox(height: 20),
          Center(
            // Center widget added here
            child: ElevatedButton(
              onPressed: _showAddToolDialog, // Call the dialog method
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '+ Add More Tools', // Text displayed on the button
                style: TextStyle(
                  color: Colors.white, // Text color
                  fontSize: 16, // Font size
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildToolList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tools.map((tool) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            '• $tool', // Add bullet character before the tool name
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        );
      }).toList(),
    );
  }
}

class DocumentDropdown extends StatefulWidget {
  final String? projectID;
  const DocumentDropdown({super.key, required this.projectID});

  @override
  _DocumentDropdownState createState() => _DocumentDropdownState();
}

class _DocumentDropdownState extends State<DocumentDropdown> {
  String? selectedDocument;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  List<Map<String, dynamic>> documents = [];

  @override
  void initState() {
    super.initState();
    if (widget.projectID != null) {
      Firestoreservice().getDocStream(widget.projectID!).listen((snapshot) {
        setState(() {
          documents = snapshot.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return {
              "name": data['docName'] ?? 'Untitled',
              "link": data['docUrl'] ?? 'https://example.com',
            };
          }).toList();
        });
      });
      if (documents.isEmpty) {
        print('Documents list is empty');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButton<String>(
            hint: const Text(
              'Documents',
              style: TextStyle(
                color: Colors.deepPurple,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            value: selectedDocument,
            isExpanded: true,
            items: documents.map((Map<String, dynamic> document) {
              return DropdownMenuItem<String>(
                value: document['name'],
                child: InkWell(
                  onTap: () => _launchURL(document['link']!),
                  child: Text(
                    document['name']!,
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedDocument = newValue;
              });
            },
          ),
          const SizedBox(height: 20),
          Center(
            // Center widget added here
            child: ElevatedButton(
              onPressed: _showAddDocumentDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '+ Add Document',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  void _showAddDocumentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Document'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(hintText: 'Enter document name')),
              TextField(
                  controller: linkController,
                  decoration:
                      const InputDecoration(hintText: 'Enter document link')),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel')),
            TextButton(onPressed: _addNewDocs, child: const Text('Add')),
          ],
        );
      },
    );
  }

  void _addNewDocs() {
    String name = nameController.text.trim();
    String link = linkController.text.trim();

    if (name.isNotEmpty && link.isNotEmpty) {
      Firestoreservice()
          .addProjectDocs(widget.projectID!, name, link)
          .then((_) {
        setState(() {
          documents.add({"name": name, "link": link});
        });
      });
    }

    nameController.clear();
    linkController.clear();
    Navigator.of(context).pop();
  }
}

class ProjectStatusWidget extends StatefulWidget {
  final String? projectID;
  const ProjectStatusWidget({super.key, required this.projectID});

  @override
  _ProjectStatusWidgetState createState() => _ProjectStatusWidgetState();
}

class _ProjectStatusWidgetState extends State<ProjectStatusWidget> {
  late String status;
  final List<String> statuses = ['In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    // Initialize with the provided status
    if (widget.projectID != null) {
      Firestoreservice()
          .isProjectCompleted(widget.projectID!)
          .then((isCompleted) {
        setState(() {
          status = isCompleted ? 'Completed' : 'In Progress';
        });
      });
    }
  }

  void changeStatus() {
    Firestoreservice().getProjectOwner(widget.projectID!).then((ownerID) {
      if (ownerID == FirebaseAuth.instance.currentUser?.uid) {
        bool isCompleted = status == 'Completed';
        Firestoreservice()
            .updateProjectCompletionStatus(widget.projectID!, !isCompleted)
            .then((_) {
          setState(() {
            status = !isCompleted ? 'Completed' : 'In Progress';
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You are not authorized to change the status')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define the icon and color based on the status
    IconData statusIcon;
    Color statusColor;

    switch (status) {
      case 'Upcoming':
        statusIcon = Icons.access_time;
        statusColor = Colors.orange;
        break;
      case 'In Progress':
        statusIcon = Icons.autorenew;
        statusColor = Colors.blue;
        break;
      case 'Completed':
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        break;
      default:
        statusIcon = Icons.help_outline;
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Space between items
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 28),
              const SizedBox(width: 15),
              Text(
                status,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: changeStatus, // Change status on button press
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Next >', // Text displayed on the button
              style: TextStyle(
                color: Colors.white, // Text color
                fontSize: 14, // Font size
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectScheduleWidget extends StatefulWidget {
  final String? projectID;
  const ProjectScheduleWidget({super.key, required this.projectID});

  @override
  _ProjectScheduleWidgetState createState() => _ProjectScheduleWidgetState();
}

class _ProjectScheduleWidgetState extends State<ProjectScheduleWidget> {
  List<Map<String, dynamic>> phases = [];

  @override
  void initState() {
    super.initState();
    if (widget.projectID != null) {
      Firestoreservice()
          .getScheduleStream(widget.projectID!)
          .listen((snapshot) {
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

  final TextEditingController phaseController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  // Flag to control visibility of input fields
  //bool _isAddingPhase = false;

  // Method to add a new schedule phase
  void addNewPhase() {
    Firestoreservice().addSchedule(
      widget.projectID!,
      phaseController.text,
      DateTime.parse(startDateController.text),
      DateTime.parse(endDateController.text),
    );

    setState(() {
      phases.add({
        "phase": phaseController.text,
        "start": startDateController.text,
        "end": endDateController.text,
      });
      // Clear the controllers after adding the new phase
      phaseController.clear();
      startDateController.clear();
      endDateController.clear();
      // Hide the input fields after adding the phase
      //_isAddingPhase = false; // Set the visibility flag to false
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.97, // Set width to 97% of the screen width
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project Schedule',
            style: TextStyle(
              color: Colors.deepPurple,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Display each phase in the list
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

          TextField(
            controller: phaseController,
            decoration: const InputDecoration(
                labelText: 'Phase Name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: startDateController,
            decoration: const InputDecoration(
                labelText: 'Start Date (YYYY-MM-DD)',
                border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: endDateController,
            decoration: const InputDecoration(
                labelText: 'End Date (YYYY-MM-DD)',
                border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),

          // Button to toggle visibility of input fields
          ElevatedButton(
            onPressed: addNewPhase,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Add New Phase',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 20),

          // Input fields to add a new phase (visible only when _isAddingPhase is true)
        ],
      ),
    );
  }
}
