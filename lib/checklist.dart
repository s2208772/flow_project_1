// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flow_project_1/models/project.dart';
import 'package:flow_project_1/models/checklist_saver.dart';
import 'package:flow_project_1/services/checklist_saver_store.dart';
import 'package:flow_project_1/services/project_store.dart';
import 'project_header.dart';

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({Key? key}) : super(key: key);

  @override
  _ChecklistPageState createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  List<Task> _tasks = [];
  bool _isLoading = true;
  final Map<String, String> _userNames = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  Future<void> _loadTasks() async {
    final project = ModalRoute.of(context)?.settings.arguments as Project?;
    if (project != null) {
      final updatedProject = await ProjectStore.instance.getProject(project.name);
      await _loadUserNames(updatedProject?.allTeamMembers ?? []);
      final loaded = await ChecklistSaverStore.instance.getChecklistsByProject(project.name);
      setState(() {
        _tasks = loaded;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserNames(List<String> emails) async {
    for (final email in emails) {
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();
      if (userQuery.docs.isNotEmpty) {
        final userData = userQuery.docs.first.data();
        _userNames[email] = userData['name'] ?? email;
      } else {
        _userNames[email] = email;
      }
    }
  }

  String _getDisplayName(String email) {
    final name = _userNames[email];
    if (name != null && name.isNotEmpty && name != email) {
      return '$name ($email)';
    }
    return email;
  }

  void _addTask(Project? project) {
    final nameController = TextEditingController();
    final notesController = TextEditingController();
    String? selectedOwner = project?.owner;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Checklist Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Task Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final newTask = Task(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    notes: notesController.text,
                    projectId: project?.name ?? '',
                    isComplete: false,
                  );
                  setState(() => _tasks.add(newTask));
                  ChecklistSaverStore.instance.addChecklist(newTask);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a task name')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5C5C99)),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _editTask(Task task, Project? project) {
    final nameController = TextEditingController(text: task.name);
    final notesController = TextEditingController(text: task.notes);
    bool isComplete = task.isComplete;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Checklist Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Task Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updated = Task(
                  id: task.id,
                  name: nameController.text,
                  notes: notesController.text,
                  projectId: task.projectId,
                  isComplete: isComplete,
                );
                setState(() {
                  final i = _tasks.indexWhere((t) => t.id == task.id);
                  if (i != -1) _tasks[i] = updated;
                });
                ChecklistSaverStore.instance.updateChecklist(updated);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5C5C99)),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTask(Task task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Checklist Item'),
        content: Text('Are you sure you want to delete "${task.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _tasks.removeWhere((t) => t.id == task.id));
      ChecklistSaverStore.instance.deleteChecklist(task.id, task.projectId);
    }
  }

  void _toggleComplete(Task task) {
    final updated = Task(
      id: task.id,
      name: task.name,
      notes: task.notes,
      projectId: task.projectId,
      isComplete: !task.isComplete,
    );
    setState(() {
      final i = _tasks.indexWhere((t) => t.id == task.id);
      if (i != -1) _tasks[i] = updated;
    });
    ChecklistSaverStore.instance.updateChecklist(updated);
  }

  @override
  Widget build(BuildContext context) {
    final project = ModalRoute.of(context)?.settings.arguments as Project?;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0EA),
      appBar: project != null
          ? ProjectHeader(project: project)
          : AppBar(title: const Text('Checklist')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF5C5C99)))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Checklist for ${project?.name ?? 'Project'}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: const Color(0xFF5C5C99),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _addTask(project),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Add Task', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5C5C99),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Checklist items
                  Expanded(
                    child: _tasks.isEmpty
                        ? Center(
                            child: Text(
                              'No checklist items yet.\nTap "Add Task" to add something.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _tasks.length,
                            itemBuilder: (context, index) {
                              final task = _tasks[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  leading: Checkbox(
                                    value: task.isComplete,
                                    activeColor: const Color(0xFF5C5C99),
                                    onChanged: (_) => _toggleComplete(task),
                                  ),
                                  title: Text(
                                    task.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      decoration: task.isComplete ? TextDecoration.lineThrough : null,
                                      color: task.isComplete ? Colors.grey : Colors.black87,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (task.notes.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(task.notes, maxLines: 2, overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: task.isComplete ? Colors.grey : Colors.black54,
                                                decoration: task.isComplete ? TextDecoration.lineThrough : null,
                                                fontStyle: FontStyle.italic,
                                              )),
                                        ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Color(0xFF5C5C99)),
                                        onPressed: () => _editTask(task, project),
                                        tooltip: 'Edit',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteTask(task),
                                        tooltip: 'Delete',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}