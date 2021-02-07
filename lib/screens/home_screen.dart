import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _result = '';
  File _image;
  Future<File> _imageFile;
  ImagePicker _imagePicker = ImagePicker();

  Future<void> _captureImageFromCamera() async {
    PickedFile selectedFile = await _imagePicker.getImage(
      source: ImageSource.camera,
      maxHeight: 680.0,
      maxWidth: 970.0,
    );
    setState(() {
      _image = File(selectedFile.path);
      _performImageLabelling();
    });
  }

  Future<void> _selectImageFromGallery() async {
    PickedFile selectedFile =
        await _imagePicker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(selectedFile.path);
      _performImageLabelling();
    });
  }

  Future<void> _performImageLabelling() async {
    final FirebaseVisionImage firebaseVisionImage =
        FirebaseVisionImage.fromFile(_image);
    final TextRecognizer recognizer = FirebaseVision.instance.textRecognizer();

    VisionText visionText = await recognizer.processImage(firebaseVisionImage);

    _result = '';
    setState(() {
      for (TextBlock block in visionText.blocks) {
        final String text = block.text;
        for (TextLine line in block.lines) {
          for (TextElement element in line.elements) {
            _result += element.text + ' ';
          }
        }
        _result += '\n';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/back.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 100.0),
            Container(
              width: 250.0,
              height: 280.0,
              margin: EdgeInsets.only(top: 70.0),
              padding: EdgeInsets.only(left: 28.0, right: 18.0, bottom: 5.0),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/note.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    _result,
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20.0, right: 140.0),
              child: Stack(
                children: [
                  Stack(
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/pin.png',
                          width: 240.0,
                          height: 240.0,
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: FlatButton(
                      onPressed: () => _selectImageFromGallery(),
                      onLongPress: () => _captureImageFromCamera(),
                      child: Container(
                        margin: EdgeInsets.only(top: 25.0),
                        child: _image != null
                            ? Image.file(
                                _image,
                                width: 140.0,
                                height: 192.0,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 240.0,
                                height: 200.0,
                                child: Icon(
                                  Icons.camera_front,
                                  size: 100.0,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
