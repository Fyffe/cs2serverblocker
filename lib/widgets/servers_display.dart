import 'package:country_coder/country_coder.dart';
import 'package:cs_serverblocker/interfaces/servers_refreshed_listener.dart';
import 'package:cs_serverblocker/models/server.dart';
import 'package:cs_serverblocker/services/firewall_service.dart';
import 'package:cs_serverblocker/services/servers_service.dart';
import 'package:cs_serverblocker/widgets/rule_switch.dart';
import 'package:flutter/material.dart';
import 'package:flag/flag.dart';

class ServersDisplay extends StatefulWidget {
  final ServersService serversService;
  final FirewallService firewallService;

  const ServersDisplay({super.key, required this.serversService, 
  required this.firewallService});

  @override
  State<ServersDisplay> createState() => _ServersDisplayState();
}

class _ServersDisplayState extends State<ServersDisplay>
implements ServersRefreshedListener {
  List<Server> servers = [];
  final countries = CountryCoder.instance;

  @override
  void initState() {
    servers = widget.serversService.servers;
    widget.serversService.addServersRefreshedListener(this);
    super.initState();
  }

  @override
  void dispose() {
    widget.serversService.removeServersRefreshedListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: buildContent(),
          )
        ),
      ]
    );
  }

  Widget buildContent() => servers.isNotEmpty ? buildServers(servers) 
  : Text("Couldn't find any servers");

  Widget buildServers(List<Server> data) => ListView.builder(
    itemCount: data.length,
    itemBuilder: (context, index) {
      final server = data[index];

      return Card(
        child: ListTile(
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  "${server.name} ",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flag.fromString(countries.iso1A2Code(lat: server.geoLoc.lng, lon: server.geoLoc.lat).toString(), height: 20, width: 20)
            ]
          ),
          subtitle: Text(server.relays.isNotEmpty ? server.relays[0].ipAddress : 'no relays'),
          trailing: RuleSwitch(
            firewallService: widget.firewallService,
            associatedServerName: server.name,
          ),
        ),
      );
    },
    scrollDirection: Axis.vertical,
    shrinkWrap: true,
  );
  
  @override
  void onServersRefreshed() {
    setState(() {
      servers = widget.serversService.servers;
    });
  }
}