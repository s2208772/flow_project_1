import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flow_project_1/models/project.dart';

class ProjectHeader extends StatelessWidget implements PreferredSizeWidget {
  final Project project;
  
  const ProjectHeader({super.key, required this.project});

  Future<void> _signOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5C5C99),
            ),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await FirebaseAuth.instance.signOut();
      // Navigate to root and clear navigation stack
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Image.asset('assets/FLOW.png', height: 45),
          const SizedBox(width: 16),
          Text('${project.name}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
        ],
      ),
      backgroundColor: const Color(0xFF5C5C99),
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
          icon: const Icon(Icons.home, color: Colors.white),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/my_projects');
          },
          child: const Text('My Projects', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/summary', arguments: project);
          },
          child: const Text('Summary', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/my_tasks', arguments: project);
          },
          child: const Text('My Tasks', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/plan', arguments: project);
          },
          child: const Text('Plan', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/schedule', arguments: project);
          },
          child: const Text('Schedule', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/risks', arguments: project);
          },
          child: const Text('Risks', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () => _signOut(context),
          child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
