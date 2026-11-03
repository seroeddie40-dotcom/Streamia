import 'package:flutter/material.dart';

void main() {
  runApp(const StreamiaApp());
}

class StreamiaApp extends StatelessWidget {
  const StreamiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Streamia Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Streamia Player'),
      ),
      body: const Center(
        child: Text(
          'Willkommen bei Streamia Player!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
