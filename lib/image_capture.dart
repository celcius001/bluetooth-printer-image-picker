import 'dart:io';
import 'dart:typed_data';

import 'package:agmm_v3/db_helper.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';

class ImageCapture extends StatefulWidget {
  const ImageCapture({super.key});

  @override
  State<ImageCapture> createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {
  final ImagePicker _picker = ImagePicker();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
  );
  TextEditingController searchController = TextEditingController();
  String? _searchImagePath;
  String? _searchImageId;
  Uint8List? _signatureBytes;
  bool isSearching = false;
  bool _showSignaturePad = true;
  List<Map<String, dynamic>> imageRecord = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  /// Loads all images from the database and updates the imageRecord
  /// state variable with the result.
  Future<void> _loadImages() async {
    List<Map<String, dynamic>> images = await _dbHelper.getImages();
    setState(() {
      imageRecord = images;
    });
  }

  /// Captures an image using the device camera and inserts it into the database.
  ///
  /// If the image is successfully captured, it updates the local state to reflect
  /// the new image path and sets the searching flag to true. It also reloads the
  /// images from the database to update the image record.

  Future<void> _captureImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await _dbHelper.insertImage(image.path);
      _loadImages();
      setState(() {
        _searchImagePath = image.path;
        isSearching = true;
      });
    }
  }

  /// Updates an existing image in the database by capturing a new image
  /// using the device camera and replacing the old image path with the
  /// new one.
  ///
  /// The image ID is retrieved from the searchController text field.
  /// If the image capture is successful, the local state is updated with
  /// the new image path and the existing image record is reloaded from
  /// the database.

  Future<void> _updateImage() async {
    String id = searchController.text.trim();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await _dbHelper.updateImage(id, image.path);
      _loadImages();
      setState(() {
        _searchImagePath = image.path;
      });
    }
  }

  /// Searches the database for an image with the given path and updates the
  /// local state with the found image path and ID, if any.
  ///
  /// The image path is retrieved from the searchController text field.
  /// If the image is found in the database, the local state is updated with
  /// the found image path and ID and the searching flag is set to true.
  /// If the image is not found, the searching flag is set to false and the
  /// local state is reset to null.
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
    String? foundId = await _dbHelper.getImageName(int.parse(path));
    setState(() {
      _searchImagePath = foundPath;
      _searchImageId = foundId;
      isSearching = true;
    });
  }

  Future<void> _saveSignature() async {
    String id = searchController.text.trim();
    if (_signatureController.isNotEmpty) {
      final Uint8List? signatureBytes = await _signatureController.toPngBytes();
      if (signatureBytes != null) {
        await _dbHelper.updateSignature(int.parse(id), signatureBytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Signature saved successfully!")),
          );
        }
        signatureBytes.clear();
      }
    }
  }

  Future<void> _loadSignature() async {
    String id = searchController.text.trim();
    Uint8List? signatureBytes = await _dbHelper.getSignatureById(int.parse(id));
    if (signatureBytes != null) {
      if (mounted) {
        setState(() {
          _signatureBytes = signatureBytes;
          _showSignaturePad = false;
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("No signature found!")));
      }
    }
  }

  void _clearSignature() {
    if (mounted) {
      setState(() {
        _signatureBytes = null;
        _showSignaturePad = true;
      });
    }
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
                child: Column(
                  children: [
                    Text("Name: $_searchImageId"),
                    SizedBox(width: 10),
                    Expanded(child: (Image.file(File(_searchImagePath!)))),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child:
                          _showSignaturePad
                              ? Signature(
                                controller: _signatureController,
                                height: 200,
                                backgroundColor: Colors.white,
                              )
                              : _signatureBytes != null
                              ? Image.memory(_signatureBytes!)
                              : SizedBox.shrink(),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _clearSignature();
                            },
                            child: Text("Clear Signature"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _loadSignature();
                            },
                            child: Text("Load Signature"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _saveSignature();
                            },
                            child: Text("Save Signature"),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _updateImage();
                      },
                      child: Text("Update Image"),
                    ),
                  ],
                ),
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
