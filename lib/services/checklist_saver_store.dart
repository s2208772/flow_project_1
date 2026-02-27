import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flow_project_1/models/checklist_saver.dart';

class ChecklistSaverStore {
  static final ChecklistSaverStore instance = ChecklistSaverStore._();
  ChecklistSaverStore._();

  final CollectionReference _checklistCollection =
      FirebaseFirestore.instance.collection('checklists');

  /// Get all checklists for a specific project
  Future<List<Task>> getChecklistsByProject(String projectName) async {
    final snapshot = await _checklistCollection
        .where('projectId', isEqualTo: projectName)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Task.fromJson(data);
    }).toList();
  }

  /// Add a checklist for a project
  Future<void> addChecklist(Task checklist) async {
    await _checklistCollection.add(checklist.toJson());
  }

  /// Update a checklist
  Future<void> updateChecklist(Task checklist) async {
    final snapshot = await _checklistCollection
        .where('id', isEqualTo: checklist.id)
        .where('projectId', isEqualTo: checklist.projectId)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.update(checklist.toJson());
    }
  }

  /// Delete a checklist
  Future<void> deleteChecklist(String checklistId, String projectName) async {
    final snapshot = await _checklistCollection
        .where('id', isEqualTo: checklistId)
        .where('projectId', isEqualTo: projectName)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// Clear all checklists for a project
  Future<void> clearProjectChecklists(String projectName) async {
    final snapshot = await _checklistCollection
        .where('projectId', isEqualTo: projectName)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
