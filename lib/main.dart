import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set window properties for desktop
  await DesktopWindow.setWindowSize(const Size(800, 900));
  await DesktopWindow.setMinWindowSize(const Size(600, 700));
  // await DesktopWindow.setWindowTitle('Letter Generator - Lindo Solutions');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Letter Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
