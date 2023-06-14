import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:treasure_mapp/screens/picture_screen.dart';
import '../models/place.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, required this.place});

  final Place place;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  Place? place;
  CameraController? _controller;

  List<CameraDescription>? cameras;
  CameraDescription? camera;
  Widget? cameraPreview;
  Image? image;

  @override
  void initState() {
    setCamera().then(
      (_) {
        _controller = CameraController(camera!, ResolutionPreset.medium);
        _controller?.initialize().then((snapshot) {
          cameraPreview = Center(child: CameraPreview(_controller!));
          setState(() {
            cameraPreview = cameraPreview;
          });
          print("Camera is working correctly");
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Take Picture!"),
        actions: <Widget>[
          IconButton(
              onPressed: () async {
                XFile? path;
                // attempt to take pictures and log where it's been saved
                await _controller
                    ?.takePicture()
                    .then((value) => path = value)
                    .catchError(
                        (err) => print("Couldnt take the picture: $err"));
                MaterialPageRoute route = MaterialPageRoute(
                    builder: (context) => PictureScreen(
                        imagePath: path!.path, place: widget.place));
                Navigator.push(context, route);
              },
              icon: const Icon(Icons.camera_alt)),
        ],
      ),
      body: Container(
        child: cameraPreview,
      ),
    );
  }

  Future setCamera() async {
    cameras = await availableCameras();
    print("Success finding cameras: $cameras");
    if (cameras!.isNotEmpty) {
      camera = cameras?.first;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
