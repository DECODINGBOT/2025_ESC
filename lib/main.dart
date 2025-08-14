import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharing_items/src/service/auth_service.dart';
import 'package:sharing_items/src/service/theme_service.dart';

import 'package:sharing_items/screens/login_screen.dart';
import 'package:sharing_items/screens/home_screen.dart';

Future<void> main() async {
  // Flutter 엔진 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (_) => const HomePage(),
      },
      // 로그인 상태에 따라 홈/로그인 페이지 결정
      home: auth.isLoggedIn ? const HomePage() : const LoginPage(),
    );
  }
}
