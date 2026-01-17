import 'package:flutter/material.dart';
import 'header.dart';

class Page4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: Container(
        color: const Color(0xFFF0F0EA),
        child: Center(child: const Text('Sign Out')),
      ), 
    );
  }
}