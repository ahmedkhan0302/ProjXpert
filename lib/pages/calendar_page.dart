import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
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
  bool isLoading = true;
  Map<DateTime, List<String>> phaseDates = {}; // Store events for calendar
  int currentPhaseIndex = 0;
  DateTime? _selectedDay;
  final DateTime _focusedDay = DateTime.now();

  // Define a map to store the colors for each phase
  Map<String, Color> phaseColors = {
    'Phase 1': Colors.red,
    'Phase 2': Colors.blue,
    'Phase 3': Colors.green,
    // Add more phases and their corresponding colors here
  };

  @override
  void initState() {
    super.initState();
    checkProjectStatus(); // Fetch project and phases data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(projectName ?? 'No project found')),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildPhaseSummaryCard(), // Phase Summary Card
                    const SizedBox(height: 20),
                    TableCalendar(
                      firstDay: DateTime.utc(2023, 1, 1),
                      lastDay: DateTime.utc(2025, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: CalendarFormat.month,
                      eventLoader: _getEventsForDay, // Load events for each day
                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.deepPurple,
                          shape: BoxShape.circle,
                        ),
                        // Customize the appearance of days with events
                        outsideDaysVisible: false,
                        defaultDecoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        weekendDecoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        holidayDecoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          if (phaseDates.containsKey(day)) {
                            String phaseName = phaseDates[day]!.first;
                            Color? phaseColor = phaseColors[phaseName];
                            if (phaseColor != null) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: phaseColor,
                                  shape: BoxShape.rectangle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${day.day}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            }
                          }
                          return null;
                        },
                      ),
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// Builds the phase summary card to display current, previous, and upcoming phases
  Widget _buildPhaseSummaryCard() {
    String currentPhaseName =
        phases.isNotEmpty ? phases[currentPhaseIndex]['phaseName'] : 'N/A';
    String currentPhaseDeadline = phases.isNotEmpty
        ? phases[currentPhaseIndex]['endDate'].toString().split(' ')[0]
        : 'N/A';

    String upcomingPhaseName = (currentPhaseIndex + 1 < phases.length)
        ? phases[currentPhaseIndex + 1]['phaseName']
        : 'None';
    String upcomingPhaseDeadline = (currentPhaseIndex + 1 < phases.length)
        ? phases[currentPhaseIndex + 1]['endDate'].toString().split(' ')[0]
        : 'N/A';

    String previousPhaseName = (currentPhaseIndex > 0)
        ? phases[currentPhaseIndex - 1]['phaseName']
        : 'None';
    String previousPhaseDeadline = (currentPhaseIndex > 0)
        ? phases[currentPhaseIndex - 1]['endDate'].toString().split(' ')[0]
        : 'N/A';

    return Card(
      color: Colors.purple.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPhaseRow('Current Phase:', currentPhaseName, Colors.red,
                currentPhaseDeadline),
            const SizedBox(height: 10),
            _buildPhaseRow('Upcoming Phase:', upcomingPhaseName, Colors.blue,
                upcomingPhaseDeadline),
            const SizedBox(height: 10),
            _buildPhaseRow('Previous Phase:', previousPhaseName, Colors.yellow,
                previousPhaseDeadline),
          ],
        ),
      ),
    );
  }

  /// Builds a row for each phase detail
  Widget _buildPhaseRow(
      String label, String phaseName, Color color, String deadline) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end, // Align text to the right side
              children: [
                Text(
                  phaseName,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Deadline: $deadline',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> checkProjectStatus() async {
    setState(() => isLoading = true);
    await checkUserTeamStatus();

    String userId = FirebaseAuth.instance.currentUser!.uid;
    bool projectFound = false;

    if (teamID != null) {
      projectFound = await fetchProjectFromTeam();
    }

    if (!projectFound) {
      projectFound = await fetchUserOwnedProject(userId);
    }

    if (projectFound) {
      DocumentSnapshot projSnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectID)
          .get();

      if (projSnapshot.exists) {
        setState(() {
          projectName = projSnapshot['projectName'];
        });
      }
    }

    setState(() => isLoading = false);
  }

  Future<void> checkUserTeamStatus() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot userTeamSnapshot = await FirebaseFirestore.instance
        .collection('user_teams')
        .where('userId', isEqualTo: userId)
        .get();

    if (userTeamSnapshot.docs.isNotEmpty) {
      setState(() {
        teamID = userTeamSnapshot.docs.first['teamId'];
      });
    }
  }

  Future<bool> fetchProjectFromTeam() async {
    QuerySnapshot projectTeamSnapshot = await FirebaseFirestore.instance
        .collection('teams_projects')
        .where('teamID', isEqualTo: teamID)
        .get();

    for (var doc in projectTeamSnapshot.docs) {
      String projectId = doc['projectID'];
      bool isCompleted = await Firestoreservice().isProjectCompleted(projectId);

      if (!isCompleted) {
        await loadProjectDetails(projectId);
        return true;
      }
    }
    return false;
  }

  Future<bool> fetchUserOwnedProject(String userId) async {
    QuerySnapshot projSnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .where('ownerId', isEqualTo: userId)
        .get();

    for (var doc in projSnapshot.docs) {
      String projectId = doc.id;
      bool isCompleted = await Firestoreservice().isProjectCompleted(projectId);

      if (!isCompleted) {
        await loadProjectDetails(projectId);
        return true;
      }
    }
    return false;
  }

  Future<void> loadProjectDetails(String projectId) async {
    DocumentSnapshot projSnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .get();

    if (projSnapshot.exists) {
      setState(() {
        projectName = projSnapshot['projectName'];
        projectID = projectId;
      });
      await getBuildPhaseList();
    }
  }

  Future<void> getBuildPhaseList() async {
    if (projectID != null) {
      QuerySnapshot scheduleSnapshot =
          await Firestoreservice().getScheduleStream(projectID!).first;

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
          phaseDates = _generatePhaseDates(fetchedPhases);
        });
      }
    }
  }

  Map<DateTime, List<String>> _generatePhaseDates(
      List<Map<String, dynamic>> phases) {
    Map<DateTime, List<String>> dates = {};

    for (var phase in phases) {
      DateTime startDate = phase['startDate'];
      DateTime endDate = phase['endDate'];

      for (var day = startDate;
          day.isBefore(endDate) || day.isAtSameMomentAs(endDate);
          day = day.add(const Duration(days: 1))) {
        dates.putIfAbsent(day, () => []).add(phase['phaseName']);
      }
    }
    return dates;
  }

  List<String> _getEventsForDay(DateTime day) {
    return phaseDates[day] ?? [];
  }
}
