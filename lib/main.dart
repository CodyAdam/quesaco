import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quesaco/screens/menu.dart';
import 'package:quesaco/services/connection_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Manager(),
      child: MaterialApp(
        title: 'Multiplayer Game',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const Menu(),
      ),
    );
  }
}

