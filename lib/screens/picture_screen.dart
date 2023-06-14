import 'dart:io';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/place.dart';
import '../util/dbhelper.dart';

class PictureScreen extends StatelessWidget {
  const PictureScreen(
      {super.key, required this.imagePath, required this.place});

  final String imagePath;
  final Place place;

  @override
  Widget build(BuildContext context) {
    DbHelper helper = DbHelper();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Save picture'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              place.image = imagePath;
              // save image
              helper.insertPlace(place);
              MaterialPageRoute route =
                  MaterialPageRoute(builder: (context) => const MainMap());
              Navigator.push(context, route);
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Center(child: Image.file(File(imagePath))),
    );
  }
}
