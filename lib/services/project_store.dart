import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flow_project_1/models/project.dart';

class ProjectStore {
  static const String _key = 'projects';
  static final ProjectStore instance = ProjectStore._();
  ProjectStore._();

  Future<List<Project>> getProjects() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => Project.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> addProject(Project project) async {
    final list = await getProjects();
    list.add(project);
    await _save(list);
  }

  Future<void> deleteProject(String projectName) async {
    final list = await getProjects();
    list.removeWhere((p) => p.name == projectName);
    await _save(list);
  }

  Future<void> updateProjectStatus(String projectName, String newStatus) async {
    final list = await getProjects();
    final index = list.indexWhere((p) => p.name == projectName);
    if (index != -1) {
      list[index] = list[index].copyWith(status: newStatus);
      await _save(list);
    }
  }

  Future<void> _save(List<Project> list) async {
    final sp = await SharedPreferences.getInstance();
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await sp.setString(_key, encoded);
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key);
  }
}
