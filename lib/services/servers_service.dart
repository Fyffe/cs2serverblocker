import 'dart:convert';
import 'package:cs_serverblocker/interfaces/servers_refreshed_listener.dart';
import 'package:cs_serverblocker/models/server.dart';
import 'package:http/http.dart' as http;

class ServersService {
    final String steamRelayConfigUri = "https://api.steampowered.com/ISteamApps/GetSDRConfig/v1/?appid=730";
    final List<ServersRefreshedListener> _serversRefreshedListeners = [];

    bool _isInitialized = false;

    bool isInitialized() => _isInitialized;

    List<Server> servers = [];

    void addServersRefreshedListener(ServersRefreshedListener listener) {
      _serversRefreshedListeners.add(listener);
    }

    void removeServersRefreshedListener(ServersRefreshedListener listener) {
      _serversRefreshedListeners.remove(listener);
    }

    Future<void> refreshServers() async {
      var result = await http.get(Uri.parse(steamRelayConfigUri));

      servers.clear();
    
      Map<String, dynamic> json = jsonDecode(result.body);
      Map<String, dynamic> pops = json["pops"];
      servers = pops.entries.map((entry) => Server.fromJson(entry.value)).toList();
      
      servers.removeWhere((server) => server.relays.isEmpty);

      _isInitialized = true;

      for(var listener in _serversRefreshedListeners)
      {
        listener.onServersRefreshed();
      }
    }
}