class GeoLoc {
  final double lat;
  final double lng;

  const GeoLoc({
    required this.lat,
    required this.lng
  });

  static GeoLoc fromJson(json) => GeoLoc(
    lat: json[0] is int ? (json[0] as int).toDouble() : json[0],
    lng: json[1] is int ? (json[1] as int).toDouble() : json[1],
  );
}