import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flow_project_1/models/project.dart';

class ProjectStore {
  static final ProjectStore instance = ProjectStore._();
  ProjectStore._();

  final CollectionReference _projectsCollection =
      FirebaseFirestore.instance.collection('projects');

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  /// Get projects where the current user is owner or member
  Future<List<Project>> getProjects() async {
    final userId = _currentUserId;
    if (userId == null) return [];
    
    // Get all projects
    final snapshot = await _projectsCollection.get();
    
    // Use a Set to track unique project names to avoid duplicates
    final seenProjectNames = <String>{};
    final uniqueProjects = <Project>[];
    
    // Filter projects where user is owner OR member
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      final project = Project.fromJson(data);
      
      if ((project.userId == userId || project.memberUserIds.contains(userId)) &&
          !seenProjectNames.contains(project.name)) {
        seenProjectNames.add(project.name);
        uniqueProjects.add(project);
      }
    }
    
    return uniqueProjects;
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

  Future<void> addMember(String projectName, String memberEmail) async {
    // Look up user by email to get their userId
    final userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: memberEmail.toLowerCase())
        .get();
    
    if (userQuery.docs.isEmpty) {
      throw Exception('User with email $memberEmail not found');
    }
    
    final memberUserId = userQuery.docs.first.id;
    
    final snapshot = await _projectsCollection
        .where('name', isEqualTo: projectName)
        .get();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final projectOwnerId = data['userId'] as String?;
      
      // Don't add the owner as a member
      if (memberUserId == projectOwnerId) {
        throw Exception('Cannot add project owner as a member');
      }
      
      final currentMembers = List<String>.from(data['members'] ?? []);
      final currentMemberIds = List<String>.from(data['memberUserIds'] ?? []);
      
      if (!currentMemberIds.contains(memberUserId)) {
        currentMembers.add(memberEmail.toLowerCase());
        currentMemberIds.add(memberUserId);
        await doc.reference.update({
          'members': currentMembers,
          'memberUserIds': currentMemberIds,
        });
      }
    }
  }

  Future<void> removeMember(String projectName, String memberEmail) async {
    // Look up user by email
    final userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: memberEmail.toLowerCase())
        .get();
    
    if (userQuery.docs.isEmpty) {
      return; // User not found, nothing to remove
    }
    
    final memberUserId = userQuery.docs.first.id;
    
    final snapshot = await _projectsCollection
        .where('name', isEqualTo: projectName)
        .get();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final currentMembers = List<String>.from(data['members'] ?? []);
      final currentMemberIds = List<String>.from(data['memberUserIds'] ?? []);
      
      currentMembers.remove(memberEmail.toLowerCase());
      currentMemberIds.remove(memberUserId);
      await doc.reference.update({
        'members': currentMembers,
        'memberUserIds': currentMemberIds,
      });
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
