import 'package:flutter/material.dart';

class Page6 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page 6'),
        backgroundColor: const Color(0xFF5C5C99),
      ),
      body: Container(
        color: const Color(0xFFF0F0EA),
        child: Center(child: const Text('This is Page 6')),
      ), 
    );
  }
}