import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharing_items/src/custom/item_info.dart'; // <-- ItemInfo 파일 경로 맞게 수정

/// ===========================
///  예시 데이터 (같은 파일에 포함)
/// ===========================
final List<Map<String, dynamic>> _allItems = [
  {
    "category": "자동차",
    "title": "블랙박스 새상품",
    "location": "서울 강남구",
    "price": 85000, // int
    "period": "1일",
    "imageUrl": "https://picsum.photos/seed/blackbox/120",
    "isLike": true, // ✅ 초기 즐겨찾기
  },
  {
    "category": "전자/가전제품",
    "title": "아이패드 9세대 64GB",
    "location": "서울 송파구",
    "price": 290000,
    "period": "2주",
    "imageUrl": "https://picsum.photos/seed/ipad9/120",
    "isLike": false,
  },
  {
    "category": "의류/신발",
    "title": "나이키 에어포스 270",
    "location": "서울 마포구",
    "price": 70000,
    "period": "3일",
    "imageUrl": "https://picsum.photos/seed/airforce270/120",
    "isLike": true, // ✅ 초기 즐겨찾기
  },
  {
    "category": "자동차",
    "title": "차량용 핸드폰 거치대",
    "location": "서울 동작구",
    "price": 10000,
    "period": "1일",
    "imageUrl": "https://picsum.photos/seed/holder/120",
    "isLike": false,
  },
];

String _won(int n) => '₩${n.toString()}'; // 간단 표기

/// 앱에서 사용할 모델로 변환된 전체 카탈로그
final List<FavoriteItem> _mockCatalog = _allItems
    .map(
      (m) => FavoriteItem(
        title: m['title'] as String,
        period: m['period'] as String,
        price: _won(m['price'] as int), // String으로 변환
        imageUrl: m['imageUrl'] as String,
      ),
    )
    .toList();

/// 처음부터 즐겨찾기(isLike==true)인 타이틀 목록
final Set<String> _initiallyLikedTitles = _allItems
    .where((m) => (m['isLike'] ?? false) == true)
    .map((m) => m['title'] as String)
    .toSet();

/// ===========================
///  모델 & 프로바이더
/// ===========================
class FavoriteItem {
  final String title;
  final String period;
  final String price;
  final String imageUrl;

  FavoriteItem({
    required this.title,
    required this.period,
    required this.price,
    required this.imageUrl,
  });
}

class FavoritesProvider with ChangeNotifier {
  final List<FavoriteItem> _favorites = [];

  List<FavoriteItem> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(FavoriteItem item) {
    return _favorites.any((fav) => fav.title == item.title);
  }

  void toggleFavorite(FavoriteItem item) {
    if (isFavorite(item)) {
      _favorites.removeWhere((fav) => fav.title == item.title);
    } else {
      _favorites.add(item);
    }
    notifyListeners();
  }

  /// 예시 데이터 기준 초기 즐겨찾기 주입
  void seedByTitles(Iterable<String> titles, List<FavoriteItem> catalog) {
    _favorites
      ..clear()
      ..addAll(catalog.where((i) => titles.contains(i.title)));
    notifyListeners();
  }
}

/// ===========================
///  즐겨찾기 페이지
///  - ItemInfo 위젯으로 렌더
///  - 페이지 진입 시 1회 seed
/// ===========================
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool _seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 페이지 최초 진입 시, 예시 데이터로 초기 즐겨찾기 주입
    if (!_seeded) {
      context.read<FavoritesProvider>().seedByTitles(
        _initiallyLikedTitles,
        _mockCatalog,
      );
      _seeded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Provider를 watch해서 변경 시 빌드되도록
    final favProvider = context.watch<FavoritesProvider>();

    // 현재 즐겨찾기인 항목만 _allItems에서 필터
    final likedMaps = _allItems.where((m) {
      final item = FavoriteItem(
        title: m['title'] as String,
        period: m['period'] as String,
        price: _won(m['price'] as int),
        imageUrl: m['imageUrl'] as String,
      );
      return favProvider.isFavorite(item);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A5A73),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '즐겨찾기',
          style: TextStyle(
            fontFamily: 'NotoSans',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: likedMaps.isEmpty
            ? const Center(child: Text('즐겨찾기한 항목이 없습니다.'))
            : ListView.separated(
                itemCount: likedMaps.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final m = likedMaps[index];

                  // Provider 기준 현재 즐겨찾기 여부
                  final isFav = favProvider.isFavorite(
                    FavoriteItem(
                      title: m['title'] as String,
                      period: m['period'] as String,
                      price: _won(m['price'] as int),
                      imageUrl: m['imageUrl'] as String,
                    ),
                  );

                  return ItemInfo(
                    key: ValueKey('${m['title']}|${m['location']}'),
                    category: m['category'] as String,
                    title: m['title'] as String,
                    location: m['location'] as String,
                    price: m['price'] as int,
                    isLike: isFav, // Provider 상태 기반
                    // ⭐ 별 토글 시 Provider 갱신 + 로컬 예시데이터도 동기화(선택)
                    onLikeChanged: (liked) {
                      final favItem = FavoriteItem(
                        title: m['title'] as String,
                        period: m['period'] as String,
                        price: _won(m['price'] as int),
                        imageUrl: m['imageUrl'] as String,
                      );

                      context.read<FavoritesProvider>().toggleFavorite(favItem);

                      // (선택) 예시 데이터의 isLike도 함께 업데이트해두면 일관성 유지
                      m['isLike'] = liked;

                      // 리스트는 Provider watch로 재빌드되므로 setState는 굳이 필요 없음
                      // setState(() {});
                    },
                  );
                },
              ),
      ),
    );
  }
}
