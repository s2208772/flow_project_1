// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'header.dart';
import 'package:flow_project_1/models/project.dart';
import 'package:flow_project_1/services/project_store.dart';

class MyProjects extends StatefulWidget {
  @override
  State<MyProjects> createState() => _MyProjectsState();
}

class _MyProjectsState extends State<MyProjects> {
  late Future<List<Project>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  void _loadProjects() {
    _projectsFuture = ProjectStore.instance.getProjects();
  }

  Future<void> _refresh() async {
    setState(() => _loadProjects());
    await _projectsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: Container(
        color: const Color(0xFFF0F0EA),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'My Projects',
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF5C5C99),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'This is where you can view projects that you own or are apart of.',
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: FutureBuilder<List<Project>>(
                  future: _projectsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final projects = snapshot.data ?? [];
                    if (projects.isEmpty) {
                      return ListView(
                        children: const [
                          SizedBox(height: 40),
                          Center(child: Text('No projects yet. Create one via Create New Project.'))
                        ],
                      );
                    }

                    return Align(
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Project Name')),
                              DataColumn(label: Text('Project Owner')),
                              DataColumn(label: Text('Project Status')),
                              DataColumn(label: Text('')),
                              DataColumn(label: Text('')),
                            ],
                            rows: projects.map((p) {
                              return DataRow(cells: [
                                DataCell(Text(p.name)),
                                DataCell(Text(p.owner)),
                                DataCell(Text(p.status)),
                                DataCell(ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/summary', arguments: p.name);
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5C5C99)),
                                  child: const Text('Select', style: TextStyle(color: Colors.white)),
                                )),
                                DataCell(PopupMenuButton<String>(
                                  icon: const Icon(Icons.settings, color: Color(0xFF5C5C99)),
                                  onSelected: (value) async {
                                    if (value == 'delete') {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Delete Project', style: TextStyle(color: Color(0xFF5C5C99), fontWeight: FontWeight.bold)),
                                          content: Text('Are you sure you want to delete "${p.name}"? This cannot be undone.'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await ProjectStore.instance.deleteProject(p.name);
                                        _refresh();
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted: ${p.name}')));
                                      }
                                    } else if (value == 'add_members') {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Add members to: ${p.name}')));
                                    } else if (value == 'change_status') {
                                      final statuses = ['New', 'In progress', 'On hold', 'Completed', 'Cancelled', 'Archived'];
                                      final newStatus = await showDialog<String>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Change Status', style: TextStyle(color: Color(0xFF5C5C99), fontWeight: FontWeight.bold)),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Select a new status for "${p.name}":'),
                                              const SizedBox(height: 16),
                                              ...statuses.map((s) => ListTile(
                                                title: Text(s),
                                                leading: Radio<String>(
                                                  value: s,
                                                  groupValue: p.status,
                                                  onChanged: (_) => Navigator.pop(ctx, s),
                                                ),
                                                onTap: () => Navigator.pop(ctx, s),
                                              )),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx),
                                              child: const Text('Cancel'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (newStatus != null) {
                                        await ProjectStore.instance.updateProjectStatus(p.name, newStatus);
                                        _refresh();
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to: $newStatus')));
                                      }
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                    const PopupMenuItem(value: 'add_members', child: Text('Add members')),
                                    const PopupMenuItem(value: 'change_status', child: Text('Change status')),
                                  ],
                                )),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
