import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flow_project_1/models/risk.dart';

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
  }

  /// Delete risk
  Future<void> deleteRisk(String riskId, String projectName) async {
    final snapshot = await _risksCollection
        .where('id', isEqualTo: riskId)
        .where('projectId', isEqualTo: projectName)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
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
