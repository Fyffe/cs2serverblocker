import 'package:cs_serverblocker/common/app_styles.dart';
import 'package:cs_serverblocker/models/server.dart';
import 'package:cs_serverblocker/services/firewall_service.dart';
import 'package:cs_serverblocker/services/servers_service.dart';
import 'package:cs_serverblocker/widgets/servers_display.dart';
import 'package:cs_serverblocker/widgets/top_bar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final ServersService serversService;
  final FirewallService firewallService;

  const HomeScreen({super.key, required this.serversService, 
  required this.firewallService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Server> servers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      body: ListView(
        children: [
          TopBar(
            serversService: widget.serversService,
          ),
          ServersDisplay(
            serversService: widget.serversService,
            firewallService: widget.firewallService,
          ),
        ],
      ),
    );
  }
}
