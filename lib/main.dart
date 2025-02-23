import 'package:cs_serverblocker/common/app_theme.dart';
import 'package:cs_serverblocker/screens/splash.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ServerBlockerApp());
}

class ServerBlockerApp extends StatelessWidget {
  const ServerBlockerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      theme: AppTheme.mainTheme,
      darkTheme: AppTheme.darkTheme,
    );
  }
}
