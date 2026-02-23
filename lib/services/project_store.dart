import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flow_project_1/models/project.dart';

class ProjectStore {
  static final ProjectStore instance = ProjectStore._();
  ProjectStore._();

  final CollectionReference _projectsCollection =
      FirebaseFirestore.instance.collection('projects');

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  /// Get only projects belonging to the current user
  Future<List<Project>> getProjects() async {
    final userId = _currentUserId;
    if (userId == null) return [];
    
    final snapshot = await _projectsCollection
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Project.fromJson(data);
    }).toList();
  }

  //Link project to user
  Future<void> addProject(Project project) async {
    final userId = _currentUserId;
    if (userId == null) return;
    
    final projectWithUser = Project(
      name: project.name,
      owner: project.owner,
      type: project.type,
      targetDate: project.targetDate,
      status: project.status,
      userId: userId,
    );
    await _projectsCollection.add(projectWithUser.toJson());
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

  Future<void> addMember(String projectName, String memberName) async {
    final snapshot = await _projectsCollection
        .where('name', isEqualTo: projectName)
        .get();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final currentMembers = List<String>.from(data['members'] ?? []);
      if (!currentMembers.contains(memberName)) {
        currentMembers.add(memberName);
        await doc.reference.update({'members': currentMembers});
      }
    }
  }

  Future<void> removeMember(String projectName, String memberName) async {
    final snapshot = await _projectsCollection
        .where('name', isEqualTo: projectName)
        .get();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final currentMembers = List<String>.from(data['members'] ?? []);
      currentMembers.remove(memberName);
      await doc.reference.update({'members': currentMembers});
    }
  }

  Future<Project?> getProject(String projectName) async {
    final snapshot = await _projectsCollection
        .where('name', isEqualTo: projectName)
        .get();
    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      return Project.fromJson(data);
    }
    return null;
  }

  Future<void> clear() async {
    final snapshot = await _projectsCollection.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
