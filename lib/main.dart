import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/local_storage_service.dart';
import 'screens/home_screen.dart';
import 'screens/sirena_map_screen.dart';
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocalStorageService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sirena AlphaWeek',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.azulSirena),
        scaffoldBackgroundColor: AppColors.blanco,
      ),
      // TEMPORAL para probar SirenaMap directo mientras ajustas las
      // coordenadas — recordar devolver a "const HomeScreen()" después.
      home: const SirenaMapScreen(sucursalId: 'autopista_san_isidro'),
    );
  }
}