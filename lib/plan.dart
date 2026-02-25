// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flow_project_1/models/project.dart';
import 'project_header.dart';

class Plan extends StatelessWidget {
  const Plan({super.key});

  @override
  Widget build(BuildContext context) {
    final project = ModalRoute.of(context)?.settings.arguments as Project?;
    
    return Scaffold(
      appBar: project != null 
          ? ProjectHeader(project: project)
          : AppBar(title: const Text('Plan')),
      body: Container(
        color: const Color(0xFFF0F0EA),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(1.0),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            project?.name ?? 'N/A',
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF5C5C99),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                              children: [
                                const TextSpan(
                                  text: 'Project Owner',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: ': ${project?.owner ?? 'N/A'}\n\n'),
                                const TextSpan(
                                  text: 'Project Type',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: ': ${project?.type ?? 'N/A'}\n\n'),
                                const TextSpan(
                                  text: 'Current Status',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: ': ${project?.status ?? 'N/A'}\n\n'),
                                const TextSpan(
                                  text: 'Target End Date',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: ': ${project?.targetDate ?? 'N/A'}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                              side: BorderSide(color: const Color(0xFF5C5C99), width: 5),
                              shadowColor: const Color(0xFF5C5C99).withOpacity(0.5),
                              minimumSize: const Size(300, 70),
                            ),
                            child:
                            Text(
                              'Whiteboard',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF5C5C99),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                              side: BorderSide(color: const Color(0xFF5C5C99), width: 5),
                              minimumSize: const Size(300, 70),
                            ),
                            child:
                            Text(
                              'Prototype',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF5C5C99),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
