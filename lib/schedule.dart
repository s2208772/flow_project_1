import 'package:flutter/material.dart';
import 'project_header.dart';

class Schedule extends StatelessWidget {
  const Schedule({super.key});

  @override
  Widget build(BuildContext context) {
    final projectName = ModalRoute.of(context)?.settings.arguments as String? ?? 'Unknown Project';
    
    return Scaffold(
      appBar: ProjectHeader(projectName: projectName),
      body: Container(
        color: const Color(0xFFF0F0EA),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Schedule',
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF5C5C99),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
