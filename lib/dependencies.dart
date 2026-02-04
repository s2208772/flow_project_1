import 'package:flutter/material.dart';
import 'package:flow_project_1/models/project.dart';
import 'project_header.dart';

class Dependencies extends StatelessWidget {
  const Dependencies({super.key});

  @override
  Widget build(BuildContext context) {
    final project = ModalRoute.of(context)?.settings.arguments as Project?;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0EA),
      appBar: project != null
          ? ProjectHeader(project: project)
          : AppBar(title: const Text('Dependencies')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dependencies',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF5C5C99),
                    fontWeight: FontWeight.bold,
                  ),
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
                child: const Center(
                  child: Text(
                    'Dependencies will be displayed here',
                    style: TextStyle(
                      color: Color(0xFF5C5C99),
                      fontSize: 16,
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
