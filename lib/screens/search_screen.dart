// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharing_items/const/colors.dart';
import 'package:sharing_items/src/custom/item_info.dart';
import 'package:sharing_items/src/service/favorites_provider.dart';

class SearchScreen extends StatefulWidget {
  final TextEditingController? searchController;

  const SearchScreen({super.key, this.searchController});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  // 접힌 상태에서 상단 패널(화살표 영역) 높이
  static const double _collapsedPanelHeight = 50;

  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.directions_car, "label": "자동차용품"},
    {"icon": Icons.home, "label": "생활용품"},
    {"icon": Icons.sports, "label": "스포츠용품"},
    {"icon": Icons.pets, "label": "애완동물"},
    {"icon": Icons.flight, "label": "여행/기행"},
    {"icon": Icons.checkroom, "label": "의류/신발"},
    {"icon": Icons.devices, "label": "전자/가전제품"},
    {"icon": Icons.category, "label": "기타"},
  ];

  late final TextEditingController _internalController;
  TextEditingController get _controller =>
      widget.searchController ?? _internalController;

  // 카테고리 패널 상태/애니메이션 & 선택 상태
  bool _showCategoryPanel = false;
  late final AnimationController _arrowCtrl;
  final Set<String> _selectedCategories = {};

  @override
  void initState() {
    super.initState();
    _internalController = TextEditingController();
    _controller.addListener(() => setState(() {})); // 검색어 변경 시 재빌드

    _arrowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    if (widget.searchController == null) {
      _internalController.dispose();
    }
    _arrowCtrl.dispose();
    super.dispose();
  }

  void _clearSearch() => _controller.clear();

  void _toggleCategoryPanel() {
    setState(() => _showCategoryPanel = !_showCategoryPanel);
    if (_showCategoryPanel) {
      _arrowCtrl.forward();
    } else {
      _arrowCtrl.reverse();
    }
  }

  void _toggleCategory(String label) {
    setState(() {
      if (_selectedCategories.contains(label)) {
        _selectedCategories.remove(label);
      } else {
        _selectedCategories.add(label);
      }
    });
  }

  // provider의 전체 데이터에서 현재 조건으로 필터링
  List<Map<String, dynamic>> _filtered(
      List<Map<String, dynamic>> allItems) {
    final q = _controller.text.trim().toLowerCase();
    return allItems.where((item) {
      final title = (item['title'] as String).toLowerCase();
      final category = item['category'] as String;

      final matchQuery = q.isEmpty || title.contains(q);
      final matchCategory =
          _selectedCategories.isEmpty || _selectedCategories.contains(category);

      return matchQuery && matchCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Provider 감시: 즐겨찾기 변경 시 자동 재빌드
    final fav = context.watch<FavoritesProvider>();
    final results = _filtered(fav.all);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(128),
        child: AppBar(
          backgroundColor: pointColorWeak,
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "검색",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox.shrink(),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // 검색창
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: "원하시는 물건을 검색해주세요.",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: (_controller.text.isNotEmpty)
                            ? IconButton(
                                onPressed: _clearSearch,
                                icon: const Icon(Icons.clear),
                                tooltip: "지우기",
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // 리스트(배경). 접힌 헤더 높이만큼 top 여백을 두고 채움.
          Positioned.fill(
            top: _collapsedPanelHeight,
            child: IgnorePointer(
              ignoring: _showCategoryPanel, // 패널 열리면 리스트 터치 막기
              child: _resultList(results, fav),
            ),
          ),

          // 상단 카테고리 패널(접혔을 때는 화살표 영역만, 펼치면 그 아래 Grid가 오버레이)
          Positioned(top: 0, left: 0, right: 0, child: _categoryTab()),
        ],
      ),
    );
  }

  Widget _summaryBar(int count) {
    final selectedText =
        _selectedCategories.isEmpty ? "전체" : _selectedCategories.join(", ");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            "검색 결과 $count개 · 카테고리: $selectedText",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  // 결과 리스트(요약바 + 아이템들). 즐겨찾기 표시는 Provider 기준.
  Widget _resultList(List<Map<String, dynamic>> results, FavoritesProvider fav) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _summaryBar(results.length)),
        if (results.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text("검색 결과가 없어요.", style: TextStyle(fontSize: 16)),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final m = results[index];
                final id = m['id'] as String;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ItemInfo(
                    key: ValueKey(id),
                    category: m['category'] as String,
                    title: m['title'] as String,
                    location: m['location'] as String,
                    price: m['price'] as int,
                    isLike: fav.isFavoriteById(id),
                    onLikeChanged: (_) =>
                        context.read<FavoritesProvider>().toggleById(id), // 토글
                  ),
                );
              },
              childCount: results.length,
            ),
          ),
      ],
    );
  }

  // 상단 카테고리 패널(화살표 + 펼치면 Grid)
  Widget _categoryTab() {
    return Container(
      decoration: BoxDecoration(
        color: pointColorWeak,
        boxShadow: const [
          BoxShadow(blurRadius: 6, color: Colors.black12),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: _collapsedPanelHeight,
            child: Center(
              child: IconButton(
                tooltip: _showCategoryPanel ? "카테고리 접기" : "카테고리 펼치기",
                onPressed: _toggleCategoryPanel,
                icon: RotationTransition(
                  turns: Tween<double>(begin: 0, end: 0.5).animate(_arrowCtrl),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: widgetbackgroundColor,
                  ),
                ),
              ),
            ),
          ),
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _showCategoryPanel
                  ? Padding(
                      padding: const EdgeInsets.all(8),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: categories.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final label = category['label'] as String;
                          final selected =
                              _selectedCategories.contains(label);

                          return Card(
                            color: selected
                                ? widgetbackgroundColor.withOpacity(0.7)
                                : widgetbackgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => _toggleCategory(label),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    category['icon'],
                                    size: 28,
                                    color: Colors.blueGrey,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    label,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
