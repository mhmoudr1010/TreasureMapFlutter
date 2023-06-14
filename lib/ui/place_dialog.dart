import 'dart:io';

import 'package:flutter/material.dart';
import 'package:treasure_mapp/screens/camera_screen.dart';

import '../models/place.dart';
import '../util/dbhelper.dart';

class PlaceDialog extends StatefulWidget {
  bool isNew;
  Place place;

  PlaceDialog({
    super.key,
    required this.place,
    required this.isNew,
  });

  @override
  State<PlaceDialog> createState() => _PlaceDialogState();
}

class _PlaceDialogState extends State<PlaceDialog> {
  var txtName = TextEditingController();
  var txtLat = TextEditingController();
  var txtLon = TextEditingController();

  List<Place> places = [];

  @override
  Widget build(BuildContext context) {
    DbHelper helper = DbHelper();
    txtName.text = widget.place.name;
    txtLat.text = widget.place.lat.toString();
    txtLon.text = widget.place.long.toString();
    return AlertDialog(
      title: const Text("Place"),
      content: SingleChildScrollView(
        child: Column(children: [
          TextField(
            controller: txtName,
            decoration: const InputDecoration(hintText: 'Name'),
          ),
          TextField(
            controller: txtLat,
            decoration: const InputDecoration(hintText: 'Latitude'),
          ),
          TextField(
            controller: txtLon,
            decoration: const InputDecoration(hintText: 'Longitude'),
          ),
          (widget.place.image != '')
              ? Image.file(File(widget.place.image))
              : Container(),
          IconButton(
              onPressed: () {
                if (widget.isNew) {
                  helper.insertPlace(widget.place).then(
                    (data) {
                      widget.place.id = data;
                      MaterialPageRoute route = MaterialPageRoute(
                        builder: (context) => CameraScreen(place: widget.place),
                      );
                      Navigator.push(context, route);
                    },
                  );
                } else {
                  MaterialPageRoute route = MaterialPageRoute(
                    builder: (context) => CameraScreen(place: widget.place),
                  );
                  Navigator.push(context, route);
                }
              },
              icon: const Icon(Icons.camera_front)),
          ElevatedButton(
            onPressed: () {
              widget.place.name = txtName.text;
              widget.place.lat = double.tryParse(txtLat.text)!;
              widget.place.long = double.tryParse(txtLon.text)!;
              helper.insertPlace(widget.place);
              Navigator.pop(context);
              setState(() {
                helper
                    .getPlaces()
                    .then((value) => places = value)
                    .catchError((err) => print("err"));
              });
            },
            child: const Text("Ok"),
          ),
        ]),
      ),
    );
  }
}
