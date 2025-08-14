import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharing_items/src/service/auth_service.dart';

/// 홈페이지
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController itemController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "홈"),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: SingleChildScrollView(child: Text('body')),
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 1),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final TextEditingController? searchController;
  final bool showSearch;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.searchController,
    this.showSearch = false,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(140);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF213555),
      elevation: 0,
      flexibleSpace: Padding(
        padding: EdgeInsets.only(top: 40, left: 24, right: 24, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Center(
                  /// 가운데 부분 채우기
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "원하시는 물건을 검색해주세요.",
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(
            "로그아웃",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          onPressed: () {
            // 로그아웃
            context.read<AuthService>().signOut();
            // 로그인 페이지로 이동
            /*
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
                */
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    );
  }
}

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({Key? key, required this.currentIndex})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: const Color(0xFFF5EFE7),
      unselectedItemColor: Colors.grey,
      selectedItemColor: const Color(0xFF213555),
      type: BottomNavigationBarType.fixed,
      onTap: (int index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/category');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/favorites');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/mypage');
            break;
          default:
            Navigator.pushReplacementNamed(context, '/home');
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: '카테고리'),
        BottomNavigationBarItem(icon: Icon(Icons.star), label: '즐겨찾기'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
      ],
    );
  }
}
