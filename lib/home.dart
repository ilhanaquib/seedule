import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seedule/gemini.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // variables
    File? _image;
    final _picker = ImagePicker();

    // functions
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Seedule'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, 
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
          ],
        ),
      ),
    );
  }
}
