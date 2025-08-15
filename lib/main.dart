import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sharing_items/src/service/auth_service.dart';
import 'package:sharing_items/src/service/favorites_provider.dart';
import 'package:sharing_items/src/service/theme_service.dart';
import 'package:sharing_items/screens/favorites_screen.dart'; // FavoritesProvider가 여기 있다면 유지
import 'package:sharing_items/screens/detail_screen.dart'; // ✅ DetailScreen/DetailItem 경로 확인

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 로그인 분기 대신 상세페이지를 홈으로 바로 띄움
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DetailScreen(),
    );
  }
}
