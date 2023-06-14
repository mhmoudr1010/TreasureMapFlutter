class Place {
  int id;
  String name;
  double lat;
  double long;
  String image;

  Place({
    required this.id,
    required this.name,
    required this.lat,
    required this.long,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': (id == 0) ? null : id,
      'name': name,
      'lat': lat,
      'long': long,
      'image': image,
    };
  }
}
