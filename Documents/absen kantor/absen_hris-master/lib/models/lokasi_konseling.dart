class Location {
  final String name;

  Location({required this.name});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'],
    );
  }
}

class LocationResponse {
  final List<Location> data;

  LocationResponse({required this.data});

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<Location> locationList =
        list.map((i) => Location.fromJson(i)).toList();

    return LocationResponse(
      data: locationList,
    );
  }
}
