import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // google_fontsのインポート
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
        // ここで google_fonts を使ってアプリ全体のデフォルトフォントを設定します
        // オーソドックスで読みやすい 'Noto Sans JP' を指定しています
        textTheme: GoogleFonts.notoSansJpTextTheme(
          ThemeData.light().textTheme,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}