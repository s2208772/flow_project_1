import 'package:flutter/material.dart';

class Page7 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page 7'),
        backgroundColor: const Color(0xFF5C5C99),
      ),
      body: Container(
        color: const Color(0xFFF0F0EA),
        child: Center(child: const Text('This is Page 7')),
      ), 
    );
  }
}