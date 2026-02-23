import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flow_project_1/models/project.dart';
import 'package:flow_project_1/models/risk.dart';
import 'package:flow_project_1/services/risk_store.dart';
import 'package:flow_project_1/services/project_store.dart';
import 'project_header.dart';

class Risks extends StatefulWidget {
  final Project? project;
  const Risks({super.key, this.project});

  @override
  State<Risks> createState() => _RisksState();
}

class _RisksState extends State<Risks> {
  List<Risk> risks = [];
  Project? _project;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final Map<String, String> _userNames = {};

  @override
  void initState() {
    super.initState();
    _loadRisks();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRisks() async {
    final project = widget.project ?? ModalRoute.of(context)?.settings.arguments as Project?;
    if (project != null) {
      final updatedProject = await ProjectStore.instance.getProject(project.name);
      final loadedRisks = await RiskStore.instance.getRisksByProject(project.name);
      await _loadUserNames(updatedProject?.allTeamMembers ?? []);
      
      setState(() {
        _project = updatedProject;
        risks = loadedRisks;
      });
    }
  }

  Future<void> _loadUserNames(List<String> emails) async {
    final names = <String, String>{};
    for (final email in emails) {
      try {
        final userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email.toLowerCase())
            .limit(1)
            .get();
        
        if (userQuery.docs.isNotEmpty) {
          final userData = userQuery.docs.first.data();
          names[email] = userData['name'] ?? email;
        } else {
          names[email] = email;
        }
      } catch (e) {
        names[email] = email;
      }
    }
    _userNames.addAll(names);
  }

  String _getDisplayName(String email) {
    final name = _userNames[email];
    if (name != null && name.isNotEmpty && name != email) {
      return '$name ($email)';
    }
    return email;
  }

  void _addRisk(Project? project) {
    final descriptionController = TextEditingController();
    final impactController = TextEditingController();
    final responseController = TextEditingController();
    final notesController = TextEditingController();
    String? selectedSeverity = 'Medium';
    String? selectedOwner = project?.owner;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Risk'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description of Risk',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: impactController,
                  decoration: const InputDecoration(
                    labelText: 'Impact',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: responseController,
                  decoration: const InputDecoration(
                    labelText: 'Response',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedSeverity,
                  items: const [
                    DropdownMenuItem(value: 'Low', child: Text('Low')),
                    DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'High', child: Text('High')),
                    DropdownMenuItem(value: 'Critical', child: Text('Critical')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedSeverity = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Severity',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedOwner,
                  items: project?.allTeamMembers.map((member) {
                    final displayText = member == project.owner 
                        ? '${_getDisplayName(member)} - Project Manager' 
                        : _getDisplayName(member);
                    return DropdownMenuItem(
                      value: member,
                      child: Text(displayText),
                    );
                  }).toList() ?? [],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedOwner = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Owner',
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
                  maxLines: 2,
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
                if (descriptionController.text.isNotEmpty) {
                  final newRisk = Risk(
                    id: (risks.length + 1).toString(),
                    description: descriptionController.text,
                    impact: impactController.text,
                    response: responseController.text,
                    severity: selectedSeverity ?? 'Medium',
                    owner: selectedOwner ?? '',
                    notes: notesController.text,
                    projectId: project?.name ?? '',
                  );
                  setState(() {
                    risks.add(newRisk);
                  });
                  RiskStore.instance.addRisk(newRisk);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a description')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C5C99),
              ),
              child: const Text(
                'Add Risk',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editRisk(Risk risk, Project? project) {
    final descriptionController = TextEditingController(text: risk.description);
    final impactController = TextEditingController(text: risk.impact);
    final responseController = TextEditingController(text: risk.response);
    final notesController = TextEditingController(text: risk.notes);
    String? selectedSeverity = risk.severity;
    String? selectedOwner = risk.owner;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Risk'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description of Risk',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: impactController,
                  decoration: const InputDecoration(
                    labelText: 'Impact',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: responseController,
                  decoration: const InputDecoration(
                    labelText: 'Response',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedSeverity,
                  items: const [
                    DropdownMenuItem(value: 'Low', child: Text('Low')),
                    DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'High', child: Text('High')),
                    DropdownMenuItem(value: 'Critical', child: Text('Critical')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedSeverity = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Severity',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedOwner,
                  items: project?.allTeamMembers.map((member) {
                    final displayText = member == project.owner 
                        ? '${_getDisplayName(member)} - Project Manager' 
                        : _getDisplayName(member);
                    return DropdownMenuItem(
                      value: member,
                      child: Text(displayText),
                    );
                  }).toList() ?? [],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedOwner = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Owner',
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
                  maxLines: 2,
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
                final updatedRisk = Risk(
                  id: risk.id,
                  description: descriptionController.text,
                  impact: impactController.text,
                  response: responseController.text,
                  severity: selectedSeverity ?? 'Medium',
                  owner: selectedOwner ?? '',
                  notes: notesController.text,
                  projectId: risk.projectId,
                );
                setState(() {
                  final index = risks.indexWhere((r) => r.id == risk.id);
                  if (index != -1) {
                    risks[index] = updatedRisk;
                  }
                });
                RiskStore.instance.updateRisk(updatedRisk);
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

  void _deleteRisk(Risk risk) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Risk'),
        content: Text('Are you sure you want to delete risk "${risk.description}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        risks.removeWhere((r) => r.id == risk.id);
      });
      RiskStore.instance.deleteRisk(risk.id, risk.projectId, riskDescription: risk.description);
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.deepOrange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project ?? ModalRoute.of(context)?.settings.arguments as Project?;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0EA),
      appBar: project != null
          ? ProjectHeader(project: project)
          : AppBar(title: const Text('Risks')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Risks',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFF5C5C99),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search for risk by description or ID',
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF5C5C99)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _addRisk(project),
                      icon: const Icon(Icons.add),
                      label: const Text('Add new risk'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5C5C99),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5C5C99).withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: risks.isEmpty
                    ? const Center(
                        child: Text(
                          'No risks for this project. Add one using the + button.',
                          style: TextStyle(
                            color: Color(0xFF5C5C99),
                            fontSize: 16,
                          ),
                        ),
                      )
                    : Scrollbar(
                        controller: _verticalScrollController,
                        thumbVisibility: true,
                        thickness: 10,
                        child: Scrollbar(
                          controller: _horizontalScrollController,
                          thumbVisibility: true,
                          thickness: 10,
                          notificationPredicate: (notification) => notification.depth == 1,
                          child: SingleChildScrollView(
                            controller: _verticalScrollController,
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              controller: _horizontalScrollController,
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: 1400,
                                child: DataTable(
                                  showCheckboxColumn: false,
                                  columns: const [
                                    DataColumn(label: Text('Risk ID')),
                                    DataColumn(label: Text('Description of Risk')),
                                    DataColumn(label: Text('Impact')),
                                    DataColumn(label: Text('Response')),
                                    DataColumn(label: Text('Severity')),
                                    DataColumn(label: Text('Owner')),
                                    DataColumn(label: Text('Notes')),
                                    DataColumn(label: Text('Actions')),
                                  ],
                                  rows: risks
                                      .where((risk) => _searchQuery.isEmpty ||
                                          risk.description.toLowerCase().contains(_searchQuery) ||
                                          risk.id.toLowerCase().contains(_searchQuery))
                                      .map((risk) => DataRow(
                                            onSelectChanged: (_) => _editRisk(risk, project),
                                            cells: [
                                              DataCell(SizedBox(width: 50, child: Text(risk.id))),
                                              DataCell(GestureDetector(
                                                onTap: () => _editRisk(risk, project),
                                                child: Tooltip(
                                                  message: risk.description,
                                                  child: SizedBox(
                                                    width: 180,
                                                    child: Text(
                                                      risk.description,
                                                      style: const TextStyle(decoration: TextDecoration.underline, color: Color(0xFF5C5C99)),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                ),
                                              )),
                                              DataCell(Tooltip(
                                                message: risk.impact,
                                                child: SizedBox(
                                                  width: 150,
                                                  child: Text(risk.impact, overflow: TextOverflow.ellipsis, maxLines: 2),
                                                ),
                                              )),
                                              DataCell(Tooltip(
                                                message: risk.response,
                                                child: SizedBox(
                                                  width: 150,
                                                  child: Text(risk.response, overflow: TextOverflow.ellipsis, maxLines: 2),
                                                ),
                                              )),
                                              DataCell(SizedBox(
                                                width: 80,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: _getSeverityColor(risk.severity).withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    risk.severity,
                                                    style: TextStyle(
                                                      color: _getSeverityColor(risk.severity),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              )),
                                              DataCell(Tooltip(
                                                message: risk.owner,
                                                child: SizedBox(width: 120, child: Text(risk.owner, overflow: TextOverflow.ellipsis)),
                                              )),
                                              DataCell(Tooltip(
                                                message: risk.notes,
                                                child: SizedBox(
                                                  width: 120,
                                                  child: Text(risk.notes, overflow: TextOverflow.ellipsis, maxLines: 2),
                                                ),
                                              )),
                                              DataCell(
                                                SizedBox(
                                                  width: 80,
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(Icons.edit, color: Color(0xFF5C5C99), size: 18),
                                                        onPressed: () => _editRisk(risk, project),
                                                        tooltip: 'Edit',
                                                        padding: EdgeInsets.zero,
                                                        constraints: const BoxConstraints(),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      IconButton(
                                                        icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                                        onPressed: () => _deleteRisk(risk),
                                                        tooltip: 'Delete',
                                                        padding: EdgeInsets.zero,
                                                        constraints: const BoxConstraints(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ))
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
