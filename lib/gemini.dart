import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:seedule/auth/secret.dart';
import 'package:seedule/global.dart';
import 'package:seedule/schedule.dart';

class GeminiWidget extends StatefulWidget {
  const GeminiWidget({super.key, required this.image});
  final File image;

  @override
  State<GeminiWidget> createState() => _GeminiWidgetState();
}

class _GeminiWidgetState extends State<GeminiWidget> {
  Map<String, String>? plantInfo;
  Uint8List? imageByte;
  String? rawResponse;
  bool isLoading = true;

  final _generativeModel = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: geminiKey,
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
    if (imageByte == null) return;

    setState(() {
      isLoading = true;
      rawResponse = null;
      plantInfo = null;
    });

    final prompt = '''
You are a plant expert. Given the image, identify the plant and return the response in this structured format:

Plant Name: [Common name]
Scientific Name: [Scientific name]
Description: [1-2 lines about the plant]
Plant Type: [Seed / Sapling / Full-grown plant]
Care Tips: [Short care tips]

Only use this structure. Do not add anything extra.
''';

    final content = [
      Content.multi([TextPart(prompt), DataPart('image/jpeg', imageByte!)]),
    ];

    try {
      final genResponse = await _generativeModel.generateContent(content);
      final text = genResponse.text ?? '';

      setState(() {
        rawResponse = text;
        plantInfo = _parsePlantResponse(text);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        rawResponse = 'Failed to generate content: $e';
        isLoading = false;
      });
    }
  }

  Map<String, String> _parsePlantResponse(String response) {
    final lines = response.split('\n');
    final data = <String, String>{};

    for (var line in lines) {
      if (line.contains(':')) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          data[parts[0].trim()] = parts.sublist(1).join(':').trim();
        }
      }
    }
    return data;
  }

  void goToChecklist() {
    if (plantInfo != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  ScheduleScreen(plant: plantInfo!['Plant Name'] ?? 'Unknown'),
        ),
      );
    }
  }

  Widget buildPlantInfoCard() {
    if (plantInfo == null) {
      return Text(rawResponse ?? 'No response yet.');
    }

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children:
              plantInfo!.entries.map((entry) {
                return ListTile(
                  title: Text(
                    entry.key,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(entry.value),
                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                );
              }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seedule', style: TextStyle(color: AppColors.background)),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                if (imageByte != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(imageByte!, height: 200),
                  ),
                SizedBox(height: 20),
                isLoading ? CircularProgressIndicator() : buildPlantInfoCard(),
                SizedBox(height: 20),
                if (!isLoading)
                  Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: goToChecklist,
                        icon: Icon(Icons.check),
                        label: Text('Create Plan'),
                      ),
                      SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: generateResponse,
                        icon: Icon(Icons.refresh),
                        label: Text('Retry'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
