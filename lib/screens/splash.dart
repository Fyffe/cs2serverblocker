import 'package:country_coder/country_coder.dart';
import 'package:cs_serverblocker/common/app_styles.dart';
import 'package:cs_serverblocker/screens/home.dart';
import 'package:cs_serverblocker/services/firewall_service.dart';
import 'package:cs_serverblocker/services/servers_service.dart';
import 'package:cs_serverblocker/widgets/animated_loader.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ServersService serversService = ServersService();
  FirewallService firewallService = FirewallService();
  final countries = CountryCoder.instance;

  Future<void> loadApp() async {
    countries.load();
    await serversService.refreshServers();
    await firewallService.initializeRules(serversService.servers);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          serversService: serversService,
          firewallService: firewallService,
        )
      )
    );
  }

  @override
  void initState() {
    super.initState();

    loadApp();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            Image.asset(
              "assets/images/logo.jpg",
              width: 128,
            ),
            // Text(
            //   "Loading", 
            //   style: TextStyle(
            //     fontSize: 24.0,
            //   ),
            // )
            AnimatedLoader(width: 64.0)
          ],
        ),
      )
    );
  }

  bool isReady() => firewallService.isInitialized() && serversService.isInitialized();
}