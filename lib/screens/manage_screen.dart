import 'package:flutter/material.dart';
import 'package:treasure_mapp/models/place.dart';

import '../ui/place_dialog.dart';
import '../util/dbhelper.dart';

class ManagePlaces extends StatelessWidget {
  const ManagePlaces({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage places"),
      ),
      body: const PlacesList(),
    );
  }
}

class PlacesList extends StatefulWidget {
  const PlacesList({super.key});

  @override
  State<PlacesList> createState() => _PlacesListState();
}

class _PlacesListState extends State<PlacesList> {
  DbHelper helper = DbHelper();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: helper.places.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: Key(helper.places[index].name),
          onDismissed: (direction) {
            String strName = helper.places[index].name;
            helper.deletePlace(helper.places[index]);
            setState(() {
              helper.places.removeAt(index);
            });
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("$strName deleted")));
          },
          child: ListTile(
            title: Text(helper.places[index].name),
            trailing: IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => PlaceDialog(
                          place: helper.places[index], isNew: false));
                },
                icon: const Icon(Icons.edit)),
          ),
        );
      },
    );
  }
}
