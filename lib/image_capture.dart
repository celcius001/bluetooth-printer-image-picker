import 'dart:io';

import 'package:agmm_v3/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageCapture extends StatefulWidget {
  const ImageCapture({super.key});

  @override
  State<ImageCapture> createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {
  final ImagePicker _picker = ImagePicker();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  TextEditingController searchController = TextEditingController();
  String? _searchImagePath;
  bool isSearching = false;

  Future<void> _captureImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await _dbHelper.insertImage(image.path);
      setState(() {
        _searchImagePath = image.path;
        isSearching = true;
      });
    }
  }

  Future<void> _searchByPath() async {
    String path = searchController.text.trim();
    if (path.isEmpty) {
      setState(() {
        _searchImagePath = null;
        isSearching = false;
      });
      return;
    }

    String? foundPath = await _dbHelper.getImageById(int.parse(path));
    setState(() {
      _searchImagePath = foundPath;
      isSearching = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Capture')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search by ID",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(onPressed: _searchByPath, child: Text("Search")),
              ],
            ),
          ),
          if (_searchImagePath != null)
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Image.file(File(_searchImagePath!)),
              ),
            )
          else if (isSearching)
            Column(
              children: [
                Text("No Image Found. Capture a New one?"),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _captureImage,
                  child: Text("Capture"),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
