import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Flow Project (Logo placeholder)'),
      backgroundColor: const Color(0xFF5C5C99),
      elevation: 0,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/page1');
          },
          child: const Text('My Projects', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/page2');
          },
          child: const Text('FAQs', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/page3');
          },
          child: const Text('Contact Us', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/page4');
          },
          child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
