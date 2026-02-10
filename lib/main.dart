import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✨ 1. Import Provider
import 'user_model.dart';             // ✨ 2. Import UserModel
import 'splash_screen.dart'; 
import 'config/app_theme.dart';       // ✨ Import Theme

void main() {
  // ✨ 3. ครอบแอปของคุณด้วย Provider
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserModel(), // สร้าง UserModel ที่นี่
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CIT0006',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(),
      home: SplashScreen(), 
    );
  }
}