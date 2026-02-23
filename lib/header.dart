import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

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
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Flow Project (Logo placeholder)'),
      backgroundColor: const Color(0xFF5C5C99),
      elevation: 0,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/my_projects');
          },
          child: const Text('My Projects', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/contact_us');
          },
          child: const Text('Contact Us', style: TextStyle(color: Colors.white)),
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
