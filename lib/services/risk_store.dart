import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flow_project_1/models/risk.dart';
import 'package:flow_project_1/services/activity_log_store.dart';

class RiskStore {
  static final RiskStore instance = RiskStore._();
  RiskStore._();

  final CollectionReference _risksCollection =
      FirebaseFirestore.instance.collection('risks');

  /// Get all risks for a specific project
  Future<List<Risk>> getRisksByProject(String projectName) async {
    final snapshot = await _risksCollection
        .where('projectId', isEqualTo: projectName)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Risk.fromJson(data);
    }).toList();
  }

  /// Add a risk for a project
  Future<void> addRisk(Risk risk) async {
    await _risksCollection.add(risk.toJson());
    await ActivityLogStore.instance.logActivity(
      projectId: risk.projectId,
      action: 'added',
      itemType: 'risk',
      itemName: risk.description,
    );
  }

  /// Update risk
  Future<void> updateRisk(Risk risk) async {
    final snapshot = await _risksCollection
        .where('id', isEqualTo: risk.id)
        .where('projectId', isEqualTo: risk.projectId)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.update(risk.toJson());
    }
    await ActivityLogStore.instance.logActivity(
      projectId: risk.projectId,
      action: 'edited',
      itemType: 'risk',
      itemName: risk.description,
    );
  }

  /// Delete risk
  Future<void> deleteRisk(String riskId, String projectName, {String? riskDescription}) async {
    final snapshot = await _risksCollection
        .where('id', isEqualTo: riskId)
        .where('projectId', isEqualTo: projectName)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
    await ActivityLogStore.instance.logActivity(
      projectId: projectName,
      action: 'deleted',
      itemType: 'risk',
      itemName: riskDescription ?? 'Risk $riskId',
    );
  }

  /// Clear all risks for project
  Future<void> clearProjectRisks(String projectName) async {
    final snapshot = await _risksCollection
        .where('projectId', isEqualTo: projectName)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
