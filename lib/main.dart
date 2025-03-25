import 'package:flutter/material.dart';
import 'package:flutter_core_project/core/configs/theme/app_theme.dart';
import 'package:flutter_core_project/presentation/pages/splash/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
    );
  }
}
