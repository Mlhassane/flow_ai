import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flow/core/theme.dart';
import 'package:flow/services/theme_service.dart';
import 'package:flow/features/onboarding/onboarding_screen.dart';
import 'package:flow/features/main_navigation_screen.dart';
import 'package:flow/services/storage_service.dart';
import 'package:flow/providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  final onboardingComplete = await storage.isOnboardingComplete();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MyApp(showOnboarding: !onboardingComplete),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp(
      title: 'Flow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.themeMode,
      home: showOnboarding
          ? const OnboardingScreen()
          : const MainNavigationScreen(),
    );
  }
}
