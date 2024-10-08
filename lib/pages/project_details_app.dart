import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projxpert/services/firestore.dart';

class ProjectDetailsApp extends StatefulWidget {
  final String? projectID;
  const ProjectDetailsApp({super.key, required this.projectID});

  String? getprojID() => projectID;

  @override
  State<ProjectDetailsApp> createState() => _ProjectDetailsAppState();
}

class _ProjectDetailsAppState extends State<ProjectDetailsApp> {
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
                const ProjectSynopsisWidget(),
                const SizedBox(height: 30),
                const TechToolsWidget(),
                const SizedBox(height: 30),
                const DocumentDropdown(),
                const SizedBox(height: 30),
                ProjectScheduleWidget(projectID: widget.projectID!),
                const SizedBox(height: 20),
                const ProjectStatusWidget(
                    status: 'In Progress'), // Example of usage
                const SizedBox(height: 20),
              ],
            ),
          ),
        ));
  }
}

class ProjectSynopsisWidget extends StatelessWidget {
  const ProjectSynopsisWidget({super.key});

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
            "This project focuses on enhancing urban mobility through smart traffic management systems. The goal is to create a sustainable energy solution using solar panels in rural areas.",
            textAlign: TextAlign.left,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class TechToolsWidget extends StatelessWidget {
  const TechToolsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400, // Set your desired width here
      child: Container(
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
            ElevatedButton(
              onPressed: () {
                // Functionality to add more tools can be implemented later
                print('Add More Tools pressed'); // Temporary action for now
              },
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
            )
          ],
        ),
      ),
    );
  }

  Widget _buildToolList() {
    List<String> tools = ["Flutter", "Dart", "Firebase", "Figma"];

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
  const DocumentDropdown({super.key});

  @override
  _DocumentDropdownState createState() => _DocumentDropdownState();
}

class _DocumentDropdownState extends State<DocumentDropdown> {
  String? selectedDocument; // Variable to hold the selected document

  // List of documents
  final List<String> documents = [
    "Requirements",
    "Source Code",
    "Design",
  ];

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
                color: Colors.deepPurple, // Change to your desired color
                fontSize: 20, // Change to your desired size
                fontWeight: FontWeight.bold, // Optional: bold for emphasis
              ),
            ), // Initial text
            value: selectedDocument,
            isExpanded: true,
            items: documents.map((String document) {
              return DropdownMenuItem<String>(
                value: document,
                child: Text(document),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedDocument = newValue; // Update selected document
              });
            },
          ),
        ],
      ),
    );
  }
}

class ProjectStatusWidget extends StatelessWidget {
  final String status;

  const ProjectStatusWidget({super.key, required this.status});

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
        mainAxisAlignment: MainAxisAlignment.start,
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

  // Method to add a new schedule phase
  void _addNewPhase() {
    Firestoreservice().addSchedule(
      widget.projectID!,
      phaseController.text,
      DateTime.parse(startDateController.text),
      DateTime.parse(endDateController.text),
    );

    Firestoreservice().addCurrentProjectSchedule(
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
      padding: const EdgeInsets.all(60),
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
          // Input fields to add a new phase
          TextField(
            controller: phaseController,
            decoration: const InputDecoration(
              labelText: 'Phase Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: startDateController,
            decoration: const InputDecoration(
              labelText: 'Start Date (YYYY-MM-DD)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: endDateController,
            decoration: const InputDecoration(
              labelText: 'End Date (YYYY-MM-DD)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          // Button to add new phase
          ElevatedButton(
            onPressed: _addNewPhase,
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
        ],
      ),
    );
  }
}
