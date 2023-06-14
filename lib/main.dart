import 'dart:async';

import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import './screens/manage_screen.dart';
import './ui/place_dialog.dart';

import './util/dbhelper.dart';
import './models/place.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainMap(),
    );
  }
}

class MainMap extends StatefulWidget {
  const MainMap({super.key});

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  late DbHelper helper;

  final CameraPosition position =
      const CameraPosition(target: LatLng(37.4219983, -122.084), zoom: 12);

  final Completer<GoogleMapController> _completer = Completer();

  List<Marker> markers = [];

  @override
  void initState() {
    helper = DbHelper();
    _getCurrentLocation()
        .then((pos) => addMarker(pos, 'currops', 'You are here!'))
        .catchError((err) => print(err.toString()));
    // helper.insertMockData();
    _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("markers size: ${markers.length}");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Treasure Map"),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                MaterialPageRoute route = MaterialPageRoute(
                    builder: (context) => const ManagePlaces());
                Navigator.push(context, route);
              },
              icon: const Icon(Icons.list)),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: position,
        onMapCreated: (controller) {
          _completer.complete(controller);
        },
        markers: Set<Marker>.of(markers),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_location),
        onPressed: () {
          int here = markers
              .indexWhere((p) => p.markerId == const MarkerId('currops'));
          Place place;
          if (here == -1) {
            place = Place(id: 0, name: '', lat: 0, long: 0, image: '');
          } else {
            LatLng pos = markers[here].position;
            place = Place(
                id: 0,
                name: '',
                lat: pos.latitude,
                long: pos.longitude,
                image: '');
          }
          showDialog(
            context: context,
            builder: (context) => PlaceDialog(place: place, isNew: true),
          );
        },
      ),
    );
  }

  Future _getCurrentLocation() async {
    bool isGeolocationAvailable = await Geolocator.isLocationServiceEnabled();
    Position? _position;
    if (isGeolocationAvailable) {
      _position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    }
    return _position;
  }

  void addMarker(Position pos, String markerId, String markerTitle) {
    final marker = Marker(
        markerId: MarkerId(markerId),
        position: LatLng(pos.latitude, pos.longitude),
        infoWindow: InfoWindow(
          title: markerTitle,
        ),
        icon: (markerId == 'currops')
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
            : BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange));
    markers.add(marker);
    setState(() {
      markers = markers;
    });
  }

  Future _getData() async {
    await helper.openDb().catchError((err) => print(err));
    List<Place> places = await helper.getPlaces();
    for (Place p in places) {
      addMarker(
          Position(
              longitude: p.long,
              latitude: p.lat,
              timestamp: DateTime.now(),
              accuracy: 0,
              altitude: 0,
              heading: 0,
              speed: 0,
              speedAccuracy: 0),
          p.id.toString(),
          p.name);
    }
    setState(() {
      print('Succesfully updated markers');
      markers = markers;
    });
  }
}
