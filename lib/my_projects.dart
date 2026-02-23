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

  void _showMembersDialog(Project project) {
    final memberController = TextEditingController();
    List<String> currentMembers = List.from(project.members);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'Manage Team Members',
            style: TextStyle(color: Color(0xFF5C5C99), fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Project: ${project.name}'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5C5C99).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Color(0xFF5C5C99), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${project.owner} (Project Manager)',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Team Members:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (currentMembers.isEmpty)
                  const Text(
                    'No additional members yet.',
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  )
                else
                  ...currentMembers.map((member) => Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 18),
                                const SizedBox(width: 8),
                                Text(member),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18, color: Colors.red),
                              onPressed: () async {
                                await ProjectStore.instance.removeMember(project.name, member);
                                setDialogState(() {
                                  currentMembers.remove(member);
                                });
                                setState(() {});
                              },
                              tooltip: 'Remove member',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      )),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: memberController,
                        decoration: const InputDecoration(
                          labelText: 'Add new member',
                          hintText: 'Enter member email',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onSubmitted: (value) async {
                          final email = value.trim().toLowerCase();
                          if (email.isEmpty) return;
                          
                          try {
                            await ProjectStore.instance.addMember(project.name, email);
                            // Refresh project to get updated member list
                            final updatedProject = await ProjectStore.instance.getProject(project.name);
                            setDialogState(() {
                              if (updatedProject != null) {
                                currentMembers = List.from(updatedProject.members);
                              }
                            });
                            memberController.clear();
                            setState(() {});
                          } catch (e) {
                            // Error handling placeholder - to be implemented during testing
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final email = memberController.text.trim().toLowerCase();
                        if (email.isEmpty) return;
                        
                        try {
                          await ProjectStore.instance.addMember(project.name, email);
                          // Refresh project to get updated member list
                          final updatedProject = await ProjectStore.instance.getProject(project.name);
                          setDialogState(() {
                            if (updatedProject != null) {
                              currentMembers = List.from(updatedProject.members);
                            }
                          });
                          memberController.clear();
                          setState(() {});
                        } catch (e) {
                          // Error handling placeholder - to be implemented during testing
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5C5C99),
                      ),
                      child: const Text('Add', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _refresh();
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Projects',
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFF5C5C99),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(
                  width: 100,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/create_new_project');
                    },
                    icon: const Icon(Icons.add, size: 18),
                    tooltip: 'Create New Project',
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C5C99),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
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
                        children: [
                          const SizedBox(height: 30),
                          const Center(child: Text('No projects yet. Create one via Create New Project.')),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/create_new_project');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5C5C99),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 20,
                              ),
                            ),
                            child: const Text(
                              'Create New Project',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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
                                    Navigator.pushNamed(context, '/summary', arguments: p);
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
                                      _showMembersDialog(p);
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
