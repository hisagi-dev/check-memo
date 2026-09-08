import 'package:flutter/material.dart';
import 'views/home_screen.dart';

void main() {
  runApp(const ShoppingMemoApp());
}

class ShoppingMemoApp extends StatelessWidget {
  const ShoppingMemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '買い物メモ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}