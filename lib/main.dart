import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/local_storage_service.dart';
import 'services/firebase_service.dart';
import 'services/accessibility_service.dart';
import 'screens/home_screen.dart';
import 'utils/app_colors.dart';
import 'widgets/accessibility_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocalStorageService.init();
  await AccessibilityService.init();
  await FirebaseService().precargarProductos();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sirena AlphaWeek',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return AccessibilityWrapper(child: child!);
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.azulSirena),
        scaffoldBackgroundColor: AppColors.blanco,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}