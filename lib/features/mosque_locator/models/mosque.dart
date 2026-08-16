class Mosque {
  final String id;
  final String? name;
  final String? address;
  final double latitude;
  final double longitude;
  final double distanceMeters;

  const Mosque({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    this.name,
    this.address,
  });

  /// Google's "universal" maps link — opens the Maps app when installed,
  /// otherwise falls back to the web, on both Android and iOS.
  Uri get directionsUri => Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': '$latitude,$longitude',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'distanceMeters': distanceMeters,
  };

  factory Mosque.fromJson(Map<String, dynamic> json) => Mosque(
    id: json['id'] as String,
    name: json['name'] as String?,
    address: json['address'] as String?,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    distanceMeters: (json['distanceMeters'] as num).toDouble(),
  );
}
