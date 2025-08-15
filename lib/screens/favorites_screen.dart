import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  List<FavoriteItem> get favorites => _favorites;

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

  void seedByTitles(Iterable<String> titles, List<FavoriteItem> catalog) {
    _favorites
      ..clear()
      ..addAll(catalog.where((i) => titles.contains(i.title)));
    notifyListeners();
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().favorites;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "즐겨찾기 내역",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 비었을 때도 화면이 예쁘게 보이도록 Center 처리
            if (favorites.isEmpty)
              const Expanded(child: Center(child: Text('즐겨찾기한 항목이 없습니다.')))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: favorites.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = favorites[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5EFE7),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Image.network(item.imageUrl, width: 60, height: 60),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(item.period),
                                Text(item.price),
                              ],
                            ),
                          ),
                          // 즐겨찾기 페이지에서는 모두 즐겨찾기 상태이므로 '해제' 아이콘을 표시
                          IconButton(
                            icon: const Icon(Icons.star, color: Colors.blue),
                            tooltip: '즐겨찾기 해제',
                            onPressed: () {
                              context.read<FavoritesProvider>().toggleFavorite(
                                item,
                              );
                              // toggle 후 notify → favorites가 줄어들며 즉시 리스트에서 빠짐
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
