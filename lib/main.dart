import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart'; // 自動生成されたファイルをインポート
import 'views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // options を指定して初期化
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'メモ',
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.notoSansJpTextTheme(baseTheme.textTheme),
        primaryTextTheme: GoogleFonts.notoSansJpTextTheme(
          baseTheme.primaryTextTheme,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
