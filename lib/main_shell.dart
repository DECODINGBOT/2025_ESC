import 'package:flutter/material.dart';
import 'package:sharing_items/screens/search_screen.dart';
import 'package:sharing_items/screens/favorites_screen.dart';
import 'package:sharing_items/screens/home_screen.dart';
import 'package:sharing_items/screens/mypage_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _selectedIndex;

  @override
  void initState(){
    super.initState();
    _selectedIndex = 0;
  }

  final _pages = const [
    HomePage(),
    CategoryScreen(),
    FavoritesPage(),
    MyPageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: const Color(0xFFF5EFE7),
        unselectedItemColor: Colors.grey,
        selectedItemColor: const Color(0xFF213555),
        type: BottomNavigationBarType.fixed,
        onTap: (newIndex){
          setState(() {
            _selectedIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: '검색'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: '즐겨찾기'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
      ),
    );
  }
}