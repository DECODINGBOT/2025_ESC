import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharing_items/screens/category_screen.dart';
import 'package:sharing_items/screens/favorites_screen.dart';
import 'package:sharing_items/screens/write_screen.dart';
import 'package:sharing_items/src/service/auth_service.dart';
import 'package:sharing_items/src/service/theme_service.dart';

import 'package:sharing_items/screens/login_screen.dart';
import 'package:sharing_items/screens/home_screen.dart';
import 'package:sharing_items/screens/mypage_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritesProvider()), // ★ 추가
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'NanumSquareRound'),
      home: CategoryScreen(),
      debugShowCheckedModeBanner: false,

      routes: {
        '/login': (_) => LoginPage(),
        '/home': (_) => HomePage(),
        '/category': (_) => CategoryScreen(),
        '/favorites': (_) => FavoritesPage(),
        '/mypage': (_) => MyPageScreen(),
        '/write': (_) => WriteScreen(),
      },
    );
  }
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized(); // main 함수에서 async 사용하기 위함
//   await Firebase.initializeApp(); // firebase 앱 시작
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => AuthService()),
//         ChangeNotifierProvider(create: (context) => ThemeService()),
//       ],
//       child: const MyApp(),
//     ),
//   );

// }


// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     //final user = context.read<AuthService>().currentUser();
//     final user = context.watch<AuthService>().currentUser();
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,

//       ///수정된 부분
//       routes: {
//         '/login': (_) => LoginPage(),
//         '/home': (_) => HomePage(),
//       },
      
//       home: user == null ? LoginPage() : HomePage(),
//     );
//   }
// }