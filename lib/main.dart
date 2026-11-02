import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/post_service.dart';

void main() {
  runApp(const NusaInfoApp());
}

class NusaInfoApp extends StatelessWidget {
  const NusaInfoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NusaInfo Kampus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF0E7C66)),
      home: HomeScreen(service: PostService()),
    );
  }
}
