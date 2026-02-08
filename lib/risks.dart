import 'package:flutter/material.dart';
import 'package:flow_project_1/models/project.dart';
import 'project_header.dart';

class Risks extends StatelessWidget {
  const Risks({super.key});

  @override
  Widget build(BuildContext context) {
    final project = ModalRoute.of(context)?.settings.arguments as Project?;
    
    return Scaffold(
      appBar: project != null 
          ? ProjectHeader(project: project)
          : AppBar(title: const Text('Risks')),
      body: Container(
        color: const Color(0xFFF0F0EA),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Risks',
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
