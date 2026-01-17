import 'package:flutter/material.dart';
import 'page2.dart';

class ExtendedPage2 extends Page2 {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extended Page 2'),
        backgroundColor: const Color(0xFF5C5C99),
      ),
      body: Container(
        color: const Color(0xFFF0F0EA),
        child: Center(child: const Text('This is Extended Page 2')),
      ), 
    );
  }
}