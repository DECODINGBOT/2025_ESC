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
  final TextEditingController itemController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // NEW: 비로그인 상태면 로그인 화면으로 보냄
    final auth = context.read<AuthService>();
    if (!auth.isLoggedIn) {
      // build 이후에 네비게이션 수행
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>(); // CHANGED: 상태 감시
    final greetingName = auth.username ?? '사용자';

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          backgroundColor: const Color(0xFF213555),
          elevation: 0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 40, left: 24, right: 24, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // CHANGED: 타이틀에 사용자명 노출
                    Text(
                      "홈 · $greetingName님",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Center(), // 가운데 채우기용
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
                    controller: itemController,
                    decoration: const InputDecoration(
                      hintText: "원하시는 물건을 검색해주세요.",
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    onSubmitted: (q) {
                      // TODO: 검색 API 연동 시 auth.token으로 호출
                      // 예) ApiClient(token: auth.token).getJson('/api/items?query=$q')
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                "로그아웃",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                // CHANGED: 백엔드 로그아웃 + 토큰 삭제
                await context.read<AuthService>().signOutBackend();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Text(
            auth.isLoggedIn
                ? 'body (토큰 보유 중)'
                : '로그인이 필요합니다. 잠시 후 로그인 화면으로 이동합니다.',
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
              // TODO: 카테고리 화면 라우트로 교체
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 2:
              // TODO: 즐겨찾기 라우트로 교체 (인증 필요 시 auth.isLoggedIn 확인)
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 3:
              // TODO: 마이페이지 라우트로 교체 (인증 필요 시 auth.isLoggedIn 확인)
              Navigator.pushReplacementNamed(context, '/home');
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
      ),
    );
  }
}
