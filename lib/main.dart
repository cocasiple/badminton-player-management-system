import 'package:flutter/material.dart';
import 'screens/main_navigation.dart';
import 'services/app_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final appStorage = AppStorage();
  await appStorage.initialize();
  
  runApp(MyApp(appStorage: appStorage));
}

class MyApp extends StatelessWidget {
  final AppStorage appStorage;
  
  const MyApp({super.key, required this.appStorage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Badminton Player Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: MainNavigationScreen(appStorage: appStorage),
    );
  }
}
