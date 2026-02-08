import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flow_project_1/models/task.dart';

class TaskStore {
  static final TaskStore instance = TaskStore._();
  TaskStore._();

  final CollectionReference _tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  /// Get all tasks for a specific project
  Future<List<Task>> getTasksByProject(String projectName) async {
    final snapshot = await _tasksCollection
        .where('projectId', isEqualTo: projectName)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Task.fromJson(data);
    }).toList();
  }

  /// Add a task for a project
  Future<void> addTask(Task task) async {
    await _tasksCollection.add(task.toJson());
  }

  /// Update a task
  Future<void> updateTask(Task task) async {
    final snapshot = await _tasksCollection
        .where('id', isEqualTo: task.id)
        .where('projectId', isEqualTo: task.projectId)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.update(task.toJson());
    }
  }

  /// Delete a task
  Future<void> deleteTask(String taskId, String projectName) async {
    final snapshot = await _tasksCollection
        .where('id', isEqualTo: taskId)
        .where('projectId', isEqualTo: projectName)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// Clear all tasks for a project
  Future<void> clearProjectTasks(String projectName) async {
    final snapshot = await _tasksCollection
        .where('projectId', isEqualTo: projectName)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
