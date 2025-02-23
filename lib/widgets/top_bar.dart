import 'package:cs_serverblocker/common/app_styles.dart';
import 'package:cs_serverblocker/interfaces/servers_refreshed_listener.dart';
import 'package:cs_serverblocker/services/servers_service.dart';
import 'package:flutter/material.dart';

class TopBar extends StatefulWidget {
  final ServersService serversService;

  const TopBar({super.key, required this.serversService});
  
  @override
  State<StatefulWidget> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> 
implements ServersRefreshedListener {
  bool isBusy = false;

  @override
  void initState() {
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
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 16.0, 
        horizontal: 16.0
      ),
      color: AppStyles.topBarColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("CS Server Blocker"),
          // ElevatedButton(
          //   onPressed: isBusy ? null : onRefreshButtonPressed, 
          //   child: Text("Refresh"))
        ],
      ),
    );
  }
  
  @override
  void onServersRefreshed() {
    setState(() {
      isBusy = false; 
    });
  }

  void onRefreshButtonPressed() {
    widget.serversService.refreshServers(); 

    setState(() {
      isBusy = true;
    });
  }
}