import 'package:flutter/material.dart';
import 'package:seedule/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seedule',
      home: const MyHomePage(title: 'Seedule'),
    );
  }
}
