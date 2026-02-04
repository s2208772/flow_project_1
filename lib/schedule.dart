import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flow_project_1/models/project.dart';
import 'project_header.dart';

class Schedule extends StatelessWidget {
  const Schedule({super.key});

  @override
  Widget build(BuildContext context) {
    final project = ModalRoute.of(context)?.settings.arguments as Project?;
    final projectName = project?.name ?? 'No project selected';
    final targetDate = project?.targetDate;
    final formattedDate = targetDate != null 
        ? DateFormat('dd MMM yyyy').format(targetDate)
        : 'Not set';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0EA),
      appBar: project != null 
          ? ProjectHeader(project: project)
          : AppBar(title: const Text('Schedule')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project name header
            Text(
              projectName,
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF5C5C99),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Estimated Finish Date: $formattedDate',
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5C5C99),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                            child: Text(
                              'Gantt Chart',
                              style: TextStyle(
                                color: Color(0xFF5C5C99),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const Expanded(
                            child: Center(
                              child: Icon(
                                Icons.calendar_today,
                                size: 64,
                                color: Color(0xFF5C5C99),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/gantt_chart', arguments: project);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5C5C99),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              ),
                              child: const Text(
                                'Expand',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5C5C99),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                            child: Text(
                              'Schedule Dependencies',
                              style: TextStyle(
                                color: Color(0xFF5C5C99),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const Expanded(
                            child: Center(
                              child: Icon(
                                Icons.timeline,
                                size: 64,
                                color: Color(0xFF5C5C99),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/dependencies', arguments: project);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5C5C99),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              ),
                              child: const Text(
                                'Expand',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
