import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:seedule/auth/secret.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key, required this.plant});
  final String plant;

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String? response;
  final _generativeModel = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: '$geminiKey',
  );

  @override
  void initState() {
    super.initState();
    generateResponse();
  }

  void generateResponse() async {
    final plant = widget.plant;
    final prompt =
        'Based on the plant given, can you create a checklist, plan, or schedule that can be followed to ensure the plant is able to grow?';
    final content = [
      Content.multi([TextPart(plant), TextPart(prompt)]),
    ];

    try {
      final genResponse = await _generativeModel.generateContent(content);
      setState(() {
        response = genResponse.text;
      });
    } catch (e) {
      setState(() {
        response = 'Failed to generate content: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Seedule'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              response == null ? CircularProgressIndicator() : Text(response!),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: generateResponse,
                child: Text('Retry Plan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
