import 'package:flutter/material.dart';
import 'page1.dart';

class ExtendedPage1 extends Page1 {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extended Page 1'),
        backgroundColor: const Color(0xFF5C5C99),
      ),
      body: Container(
        color: const Color(0xFFF0F0EA),
        child: Center(child: const Text('This is Extended Page 1')),
      ), 
    );
  }
}