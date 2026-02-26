// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flow_project_1/models/project.dart';
import 'package:flow_project_1/models/task.dart';
import 'package:flow_project_1/models/risk.dart';
import 'package:intl/intl.dart';
import 'project_header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/risk_store.dart';
import 'services/task_store.dart';

class MyTasks extends StatefulWidget {
  const MyTasks({super.key});

  @override
  State<MyTasks> createState() => _MyTasksState();
}

class _MyTasksState extends State<MyTasks> with RouteAware {
  List<Task> _tasks = [];
  List<Risk> _risks = [];
  bool _isLoading = true;
  String _displayName = 'User';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data every time the page is shown
    if (!_isLoading) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final project = ModalRoute.of(context)?.settings.arguments as Project?;
    final user = FirebaseAuth.instance.currentUser;
    final ownerKey = user?.email?.toLowerCase() ?? '';

    if (project == null || user == null || ownerKey.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Get display name
    final name = await _getUserName(user.email);
    
    // Get all tasks and risks for the project
    final allTasks = await TaskStore.instance.getTasksByProject(project.name);
    final allRisks = await RiskStore.instance.getRisksByProject(project.name);
    
    // Filter for current user and open tasks only
    final userTasks = allTasks.where((task) => 
      task.taskOwner.toLowerCase() == ownerKey && 
      task.actualFinishDate == null
    ).toList();
    
    final userRisks = allRisks.where((risk) => 
      risk.owner.toLowerCase() == ownerKey && !risk.isClosed
    ).toList();

    setState(() {
      _displayName = name;
      _tasks = userTasks;
      _risks = userRisks;
      _isLoading = false;
    });
  }

  Future<String> _getUserName(String? email) async {
    if (email == null || email.isEmpty) return 'User';
    
    try {
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();
      
      if (userQuery.docs.isNotEmpty) {
        final userData = userQuery.docs.first.data();
        return userData['name'] ?? 'User';
      }
    } catch (e) {
      //default 'User'
    }
    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    final project = ModalRoute.of(context)?.settings.arguments as Project?;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0EA),
      appBar: project != null 
          ? ProjectHeader(project: project)
          : AppBar(title: const Text('My Tasks')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF5C5C99)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${project?.name ?? 'N/A'} Tasks',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFF5C5C99),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Welcome back, $_displayName!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total assigned items: ${_tasks.length + _risks.length} (Tasks: ${_tasks.length}, Risks: ${_risks.length})',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Here are your OPEN (no actual finish date set) assigned tasks/risks for this project:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                  ),                                   
                  Text(
                    'Overdue tasks/risks will be highlighted in red.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C5C99).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // TODO: Add your task/risk display widgets here
                  // Example structure:
                  // - Loop through _tasks and display each task
                  // - Loop through _risks and display each risk

                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: _tasks.isEmpty && _risks.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              'No tasks or risks assigned.',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.black54,
                                  ),
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tasks
                            if (_tasks.isNotEmpty) ...[
                              Text(
                                _tasks.length == 1 ? '1 Task' : '${_tasks.length} Tasks',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF5C5C99),
                                    ),
                              ),
                              const SizedBox(height: 12),
                              ...List.generate(_tasks.length, (index) {
                                final task = _tasks[index];
                                final isOverdue = task.finishDate.isBefore(DateTime.now());
                                final isComplete = task.isComplete;
                                bool isHovered = false;
                                return StatefulBuilder(
                                  builder: (context, setLocalState) {
                                    return MouseRegion(
                                      onEnter: (_) => setLocalState(() => isHovered = true),
                                      onExit: (_) => setLocalState(() => isHovered = false),
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          if (project != null) {
                                            Navigator.pushNamed(context, '/dependencies', arguments: project).then((_) => _loadData());
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: isHovered ? Colors.grey.shade300 : Colors.grey.shade50,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: isComplete ? Colors.green.shade300 : isOverdue ? Colors.red.shade300 : Colors.grey.shade300,
                                                width: isComplete || isOverdue ? 2 : 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'ID: ${task.id} - ${task.name}',
                                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                              fontWeight: FontWeight.bold,
                                                              color: isComplete ? Colors.green.shade900 : isOverdue ? Colors.red.shade900 : Colors.black87,
                                                              decoration: isComplete ? TextDecoration.lineThrough : TextDecoration.none,
                                                            ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        'Estimated Finish Date: ${task.finishDate.month}/${task.finishDate.day}/${task.finishDate.year}',
                                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                              color: isComplete ? Colors.green.shade900 : isOverdue ? Colors.red.shade900 : Colors.black87,
                                                              decoration: isComplete ? TextDecoration.lineThrough : TextDecoration.none,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                              const SizedBox(height: 16),
                            ],
                            
                            // Risks
                            if (_risks.isNotEmpty) ...[
                              Text(
                                _risks.length == 1 ? '1 Risk' : '${_risks.length} Risks',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF5C5C99),
                                    ),
                              ),
                              const SizedBox(height: 12),
                              ...List.generate(_risks.length, (index) {
                                final risk = _risks[index];
                                final isOverdue = risk.occurrenceDate.isBefore(DateTime.now());
                                bool isHovered = false;
                                return StatefulBuilder(
                                  builder: (context, setLocalState) {
                                    return MouseRegion(
                                      onEnter: (_) => setLocalState(() => isHovered = true),
                                      onExit: (_) => setLocalState(() => isHovered = false),
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          if (project != null) {
                                            Navigator.pushNamed(context, '/risks', arguments: project).then((_) => _loadData());
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: isHovered ? Colors.grey.shade300 : Colors.grey.shade50,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: isOverdue ? Colors.red.shade300 : Colors.grey.shade300,
                                                width: isOverdue ? 2 : 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'ID: ${risk.id} - ${risk.description}',
                                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                              fontWeight: FontWeight.bold,
                                                              color: isOverdue ? Colors.red.shade900 : Colors.black87,
                                                            ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        'Severity: ${risk.severity} | Expected Occurrence Date: ${DateFormat.yMMMd().format(risk.occurrenceDate)}',
                                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                              color: isOverdue ? Colors.red.shade900 : Colors.black87,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                            ],
                          ],
                        ),
                  ),
                ],
              ),
            ),
    );
  }
}