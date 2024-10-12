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
      'deadline': null,
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

  // Future<void> addCurrentProjectSchedule(String projectId, String phaseName,
  //     DateTime startDate, DateTime endDate) {
  //   return currentprojects.doc(projectId).collection('schedules').add({
  //     'phaseName': phaseName,
  //     'startDate': startDate,
  //     'endDate': endDate,
  //     'createdAt': FieldValue.serverTimestamp(),
  //   });
  // }

  Future<void> addProjectDocs(String projectId, String docName, String docUrl) {
    return projx.doc(projectId).collection('documents').add({
      'docName': docName,
      'docUrl': docUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getScheduleStream(String? projectId) {
    return projx.doc(projectId).collection('schedules').snapshots();
  }

  Stream<QuerySnapshot> getDocStream(String? projectId) {
    return projx.doc(projectId).collection('documents').snapshots();
  }

  Future<void> addTechTool(String projectId, String tool) {
    return projx.doc(projectId).update({
      'Tech_tools': FieldValue.arrayUnion([tool]),
    });
  }

  Future<List<String>> getTechTools(String projectId) async {
    DocumentSnapshot docSnapshot = await projx.doc(projectId).get();
    List<dynamic> techTools = docSnapshot['Tech_tools'] ?? [];
    return List<String>.from(techTools);
  }

  Future<void> updateProjectCompletionStatus(
      String projectId, bool isCompleted) {
    return projx.doc(projectId).update({
      'isCompleted': isCompleted,
    });
  }

  Future<bool> isProjectCompleted(String projectId) async {
    DocumentSnapshot docSnapshot = await projx.doc(projectId).get();
    return docSnapshot['isCompleted'] ?? false;
  }

  getProjectOwner(String projectId) async {
    DocumentSnapshot docSnapshot = await projx.doc(projectId).get();
    return docSnapshot['ownerId'];
  }

  Future<void> editProjectSynopsis(String projectId, String synopsis) {
    return projx.doc(projectId).update({
      'synopsis': synopsis,
    });
  }

  Future<String> getProjectSynopsis(String projectId) async {
    DocumentSnapshot docSnapshot = await projx.doc(projectId).get();
    return docSnapshot['synopsis'] ?? '';
  }

  Future<void> updateTaskStatus(String userid, String docID, bool isCompleted) {
    return tasks(userid).doc(docID).update({
      'done': isCompleted,
    });
  }
}
