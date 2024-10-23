import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:projxpert/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectViewPage extends StatefulWidget {
  final String? projectID;
  const ProjectViewPage({super.key, required this.projectID});

  @override
  State<ProjectViewPage> createState() => _ProjectViewPageState();
}

class _ProjectViewPageState extends State<ProjectViewPage> {
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
              ProjectSynopsisWidget(projectID: widget.projectID!),
              const SizedBox(height: 30),
              TechToolsWidget(projectID: widget.projectID!),
              const SizedBox(height: 30),
              DocumentDropdown(projectID: widget.projectID!),
              const SizedBox(height: 30),
              ProjectScheduleWidget(projectID: widget.projectID!),
              const SizedBox(height: 20),
              ProjectStatusWidget(projectID: widget.projectID!),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class ProjectSynopsisWidget extends StatelessWidget {
  final String projectID;
  const ProjectSynopsisWidget({super.key, required this.projectID});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: Firestoreservice().getProjectSynopsis(projectID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading synopsis'));
        } else {
          return Container(
            constraints: const BoxConstraints(
              minHeight: 100, // Minimum height
              maxHeight: 300, // Maximum height
              minWidth: double.infinity, // Minimum width (full width)
            ),
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
                  snapshot.data ?? '',
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
      },
    );
  }
}

class TechToolsWidget extends StatelessWidget {
  final String? projectID;
  const TechToolsWidget({super.key, required this.projectID});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: Firestoreservice().getTechTools(projectID!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading tech tools'));
        } else {
          return Container(
            constraints: const BoxConstraints(
              minHeight: 100, // Minimum height
              maxHeight: 200, // Maximum height
              minWidth: double.infinity, // Minimum width (full width)
            ),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: snapshot.data?.map((tool) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            '• $tool',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                          ),
                        );
                      }).toList() ??
                      [],
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class DocumentDropdown extends StatelessWidget {
  final String? projectID;
  const DocumentDropdown({super.key, required this.projectID});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestoreservice().getDocStream(projectID!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading documents'));
        } else {
          List<Map<String, dynamic>> documents = snapshot.data?.docs.map((doc) {
                var data = doc.data() as Map<String, dynamic>;
                return {
                  "name": data['docName'] ?? 'Untitled',
                  "link": data['docUrl'] ?? 'https://example.com',
                };
              }).toList() ??
              [];

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
                  onChanged: null,
                ),
              ],
            ),
          );
        }
      },
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
}

class ProjectStatusWidget extends StatelessWidget {
  final String? projectID;
  const ProjectStatusWidget({super.key, required this.projectID});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: Firestoreservice().isProjectCompleted(projectID!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading project status'));
        } else {
          String status = snapshot.data! ? 'Completed' : 'In Progress';
          IconData statusIcon =
              snapshot.data! ? Icons.check_circle : Icons.autorenew;
          Color statusColor = snapshot.data! ? Colors.green : Colors.blue;

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
      },
    );
  }
}

class ProjectScheduleWidget extends StatelessWidget {
  final String? projectID;
  const ProjectScheduleWidget({super.key, required this.projectID});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestoreservice().getScheduleStream(projectID!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading schedule'));
        } else {
          List<Map<String, dynamic>> phases = snapshot.data?.docs.map((doc) {
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
              }).toList() ??
              [];

          return Container(
            constraints: const BoxConstraints(
              minHeight: 100, // Minimum height
              maxHeight: 200, // Maximum height
              minWidth: double.infinity, // Minimum width (full width)
            ),
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
              ],
            ),
          );
        }
      },
    );
  }
}
