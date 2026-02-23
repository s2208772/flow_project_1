import 'package:flutter/material.dart';
import 'package:flow_project_1/models/project.dart';
import 'package:flow_project_1/models/activity_log.dart';
import 'package:flow_project_1/services/activity_log_store.dart';
import 'project_header.dart';

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  List<ActivityLog> _recentActivities = [];
  List<ActivityLog> _newActivities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final project = ModalRoute.of(context)?.settings.arguments as Project?;
    if (project != null) {
      final lastVisit = await ActivityLogStore.instance.getLastVisit(project.name);
      List<ActivityLog> newActivities = [];
      if (lastVisit != null) {
        newActivities = await ActivityLogStore.instance.getActivitiesSince(project.name, lastVisit);
      }

      final recentActivities = await ActivityLogStore.instance.getRecentActivities(project.name);
      
      setState(() {
        _newActivities = newActivities;
        _recentActivities = recentActivities;
        _isLoading = false;
      });
      
      await ActivityLogStore.instance.recordVisit(project.name);
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'added':
        return Icons.add_circle;
      case 'edited':
        return Icons.edit;
      case 'deleted':
        return Icons.delete;
      default:
        return Icons.info;
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'added':
        return Colors.green;
      case 'edited':
        return Colors.orange;
      case 'deleted':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  Widget _buildActivityItem(ActivityLog activity, {bool isNew = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isNew ? const Color.fromARGB(255, 255, 255, 255) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: isNew ? Border.all(color: const Color(0xFF5C5C99), width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getActionColor(activity.action).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getActionIcon(activity.action),
              color: _getActionColor(activity.action),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      activity.actionDisplay,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getActionColor(activity.action),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activity.itemTypeDisplay,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (isNew) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  activity.itemName,
                  style: const TextStyle(color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final project = ModalRoute.of(context)?.settings.arguments as Project?;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0EA),
      appBar: project != null
          ? ProjectHeader(project: project)
          : AppBar(title: const Text('Summary')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF5C5C99)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFF5C5C99),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Project Stats
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
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
                          child: Column(
                            children: [
                              const Icon(Icons.notifications_active, color: Colors.green, size: 32),
                              const SizedBox(height: 8),
                              Text(
                                '${_newActivities.length}',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                              const Text('New Updates', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
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
                          child: Column(
                            children: [
                              const Icon(Icons.task_alt, color: Colors.red, size: 32),
                              const SizedBox(height: 8),
                              Text(
                                '${_newActivities.where((a) => a.itemType == 'task').length}',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                              ),
                              const Text('New tasks', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
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
                          child: Column(
                            children: [
                              const Icon(Icons.warning_amber_outlined, color: Colors.orange, size: 32),
                              const SizedBox(height: 8),
                              Text(
                                '${_newActivities.where((a) => a.itemType == 'risk').length}',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                              const Text('New risks', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Recent Activity
                  Row(
                    children: [
                      const Icon(Icons.history, color: Color(0xFF5C5C99)),
                      const SizedBox(width: 8),
                      const Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5C5C99),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_recentActivities.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'No activity recorded yet. Add tasks or risks to see updates here.',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ..._recentActivities.map((a) {
                      final isNew = _newActivities.any((n) => n.id == a.id);
                      return _buildActivityItem(a, isNew: isNew);
                    }),
                ],
              ),
            ),
    );
  }
}