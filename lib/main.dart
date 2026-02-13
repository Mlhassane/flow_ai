import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flow/core/theme.dart';
import 'package:flow/services/theme_service.dart';
import 'package:flow/features/onboarding/onboarding_screen.dart';
import 'package:flow/features/main_navigation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isFirstRun = prefs.getBool('is_first_run') ?? true;

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: MyApp(isFirstRun: isFirstRun),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isFirstRun;
  const MyApp({super.key, required this.isFirstRun});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp(
      title: 'Flow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.themeMode,
      home: isFirstRun
          ? const OnboardingScreen()
          : const MainNavigationScreen(),
    );
  }
}
