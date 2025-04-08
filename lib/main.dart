import 'package:flutter/material.dart';
import 'package:seedule/gemini.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Seedule'),
      //home: const GeminiWidget(),
    );
  }
}
