import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharing_items/screens/home_screen.dart';

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
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().favorites;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF213555),
        elevation: 0,
        centerTitle: true, // 제목 가운데 정렬
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
            if (favorites.isEmpty)
              const SizedBox.shrink()
            else
              Expanded(
                child: ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final item = favorites[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
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
                          IconButton(
                            icon: const Icon(Icons.star, color: Colors.blue),
                            onPressed: () {
                              context.read<FavoritesProvider>().toggleFavorite(
                                item,
                              );
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
      bottomNavigationBar: CustomBottomNav(currentIndex: 2),
    );
  }
}
