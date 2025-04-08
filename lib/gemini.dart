import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:seedule/auth/secret.dart';
import 'package:seedule/schedule.dart';

class GeminiWidget extends StatefulWidget {
  const GeminiWidget({super.key, required this.image});
  final File image;

  @override
  State<GeminiWidget> createState() => _GeminiWidgetState();
}

class _GeminiWidgetState extends State<GeminiWidget> {
  String? response;
  Uint8List? imageByte;
  final _generativeModel = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: '$geminiKey',
  );

  @override
  void initState() {
    super.initState();
    convertImageToBytes();
  }

  void convertImageToBytes() async {
    final bytes = await widget.image.readAsBytes();
    setState(() {
      imageByte = bytes;
    });
    generateResponse();
  }

  void generateResponse() async {
    if (imageByte == null) {
      setState(() {
        response = 'Image is still loading...';
      });
      return;
    }

    final prompt =
        'You are a plant expert. I want you to look at the image provided which could either be of seeds, seed packets, sapling or just plants and tell me what kind of plant it is. give me both the layman name for it and the scientific name.';
    final content = [
      Content.multi([TextPart(prompt), DataPart('image/jpeg', imageByte!)]),
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

  void checklist() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScheduleScreen(plant: response!,)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Seedule'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(response ?? 'Loading response...'),
            Text('You can create schedule if this is the correct plant'),
            ElevatedButton(onPressed: checklist, child: Text('Create plan')),
            ElevatedButton(onPressed: generateResponse, child: Text('Retry')),
          ],
        ),
      ),
    );
  }
}
