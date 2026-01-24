import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flow_project_1/models/project.dart';

class ProjectStore {
  static final ProjectStore instance = ProjectStore._();
  ProjectStore._();

  final CollectionReference _projectsCollection =
      FirebaseFirestore.instance.collection('projects');

  Future<List<Project>> getProjects() async {
    final snapshot = await _projectsCollection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Store the document ID
      return Project.fromJson(data);
    }).toList();
  }

  Future<void> addProject(Project project) async {
    await _projectsCollection.add(project.toJson());
  }

  Future<void> deleteProject(String projectName) async {
    final snapshot = await _projectsCollection
        .where('name', isEqualTo: projectName)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> updateProjectStatus(String projectName, String newStatus) async {
    final snapshot = await _projectsCollection
        .where('name', isEqualTo: projectName)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.update({'status': newStatus});
    }
  }

  Future<void> clear() async {
    final snapshot = await _projectsCollection.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
