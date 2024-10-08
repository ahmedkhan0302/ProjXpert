import 'package:cloud_firestore/cloud_firestore.dart';

class Firestoreservice {
  //get collection of notes

  final CollectionReference projx =
      FirebaseFirestore.instance.collection('projects');

  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

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
}
