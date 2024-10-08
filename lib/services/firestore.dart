import 'package:cloud_firestore/cloud_firestore.dart';

class Firestoreservice {
  //get collection of notes

  final CollectionReference projx =
      FirebaseFirestore.instance.collection('projects');

  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  final CollectionReference currentprojects =
      FirebaseFirestore.instance.collection('current_projects');

  // Reference to the 'tasks' subcollection within a specific 'project' document
  CollectionReference tasks(String userId) {
    return users.doc(userId).collection('tasks');
  }

  Stream<QuerySnapshot> getProjStream() {
    final queryStream = projx.snapshots();
    return queryStream;
  }

  Future<void> addTask(String task, String userId) {
    return tasks(userId).add({
      'task': task,
      'done': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getTaskStream(String userId) {
    return tasks(userId).snapshots();
  }

  Future<DocumentSnapshot> getProjectById(String projectId) async {
    return await projx.doc(projectId).get();
  }

  Future<void> addSchedule(String projectId, String phaseName,
      DateTime startDate, DateTime endDate) {
    return projx.doc(projectId).collection('schedules').add({
      'phaseName': phaseName,
      'startDate': startDate,
      'endDate': endDate,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addCurrentProjectSchedule(String projectId, String phaseName,
      DateTime startDate, DateTime endDate) {
    return currentprojects.doc(projectId).collection('schedules').add({
      'phaseName': phaseName,
      'startDate': startDate,
      'endDate': endDate,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getScheduleStream(String? projectId) {
    return projx.doc(projectId).collection('schedules').snapshots();
  }
}
