import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:seedule/gemini.dart';
import 'package:seedule/saved_schedule.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // variables
  File? _image;
  final _picker = ImagePicker();

  // functions
  Future<void> requestPermissions() async {
    // Ask for multiple permissions
    Map<Permission, PermissionStatus> statuses =
        await [
          Permission.camera,
          Permission.storage,
          Permission.photos, // For iOS
        ].request();

    if (statuses[Permission.camera]!.isGranted &&
        (statuses[Permission.storage]!.isGranted ||
            statuses[Permission.photos]!.isGranted)) {
      print("All permissions granted!");
    } else {
      print("Some permissions denied.");
    }
  }

  void pickGallery() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      _image = File(pickedImage.path);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GeminiWidget(image: _image!)),
      );
    }
  }

  void pickCamera() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      _image = File(pickedImage.path);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GeminiWidget(image: _image!)),
      );
    }
  }

  void savedSchedule() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SavedScheduleList()),
    );
  }

  @override
  void initState() {
    super.initState();
    requestPermissions();
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Pick image from gallery"),
            ElevatedButton(
              onPressed: pickGallery,
              child: const Icon(Icons.image),
            ),
            Text("or from camera"),
            ElevatedButton(
              onPressed: pickCamera,
              child: const Icon(Icons.camera),
            ),
            Text("Saved Schedules"),
            ElevatedButton(
              onPressed: savedSchedule,
              child: const Icon(Icons.save),
            ),
          ],
        ),
      ),
    );
  }
}
