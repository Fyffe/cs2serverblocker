import 'package:cs_serverblocker/models/geoloc.dart';
import 'package:cs_serverblocker/models/relay.dart';

class Server {
  final String name;
  final GeoLoc geoLoc;
  final List<Relay> relays;

  const Server({
    required this.name,
    required this.geoLoc,
    required this.relays
  });

  static Server fromJson(json) => Server(
    name: json["desc"],
    geoLoc: GeoLoc.fromJson(json["geo"]),
    relays: relaysFromJson(json["relays"])
  );

  static List<Relay> relaysFromJson(json)
  {
    List<Relay> tmpRelays = []; 

    if(json != null)
    {
      for(dynamic relay in json)
      {
        tmpRelays.add(Relay.fromJson(relay));
      }
    }

    return tmpRelays;
  }
}