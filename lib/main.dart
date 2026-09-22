import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const GR8MelhoradoApp());
}

class GR8MelhoradoApp extends StatelessWidget {
  const GR8MelhoradoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GR8 Melhorado',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const LoginScreen(),
    );
  }
}
