import 'package:flutter/material.dart';
import 'package:sharing_items/const/colors.dart';
import 'package:sharing_items/src/custom/item_info.dart';

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

  final List<Map<String, dynamic>> _allItems = [
    {
      "category": "자동차용품",
      "title": "블랙박스 새상품",
      "location": "서울 강남구",
      "price": 85000,
    },
    {
      "category": "전자/가전제품",
      "title": "아이패드 9세대 64GB",
      "location": "서울 송파구",
      "price": 290000,
    },
    {
      "category": "의류/신발",
      "title": "나이키 에어포스 270",
      "location": "서울 마포구",
      "price": 70000,
    },
    {
      "category": "자동차용품",
      "title": "차량용 핸드폰 거치대",
      "location": "서울 동작구",
      "price": 10000,
    },
  ];

  late List<Map<String, dynamic>> _results;

  // 카테고리 패널 상태/애니메이션 & 선택 상태
  bool _showCategoryPanel = false;
  late final AnimationController _arrowCtrl;
  final Set<String> _selectedCategories = {};

  @override
  void initState() {
    super.initState();
    _internalController = TextEditingController();
    _results = List<Map<String, dynamic>>.from(_allItems);
    _controller.addListener(_applyFilters);

    _arrowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_applyFilters);
    if (widget.searchController == null) {
      _internalController.dispose();
    }
    _arrowCtrl.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final q = _controller.text.trim().toLowerCase();
    setState(() {
      _results = _allItems.where((item) {
        final title = (item['title'] as String).toLowerCase();
        final category = item['category'] as String;

        final matchQuery = q.isEmpty || title.contains(q);
        final matchCategory =
            _selectedCategories.isEmpty || _selectedCategories.contains(category);

        return matchQuery && matchCategory;
      }).toList();
    });
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
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
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
                      // 가운데 채움용
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
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
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
              child: _resultList(),
            ),
          ),

          // 상단 카테고리 패널(접혔을 때는 화살표 영역만, 펼치면 그 아래 Grid가 오버레이)
          Positioned(top: 0, left: 0, right: 0, child: _categoryTab()),
        ],
      ),
    );
  }

  // 결과 리스트(Expanded/Column 없이 단일 ListView)
  Widget _resultList() {
    if (_results.isEmpty) {
      return const Center(
        child: Text("검색 결과가 없어요.", style: TextStyle(fontSize: 16)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 0),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final item = _results[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ItemInfo(
            category: item['category'] as String,
            title: item['title'] as String,
            location: item['location'] as String,
            price: item['price'] as int,
          ),
        );
      },
    );
  }

  // 상단 카테고리 패널(화살표 + 펼치면 Grid)
  Widget _categoryTab() {
    return Container(
      decoration: BoxDecoration(
        color: pointColorWeak,
        boxShadow: const [
          BoxShadow(blurRadius: 6, color: Colors.black12), // 살짝 떠 보이게
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 내용 높이만 차지
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

          // 펼쳐지는 카테고리 Grid (오버레이로 리스트 위에 내려옴)
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
                          final selected = _selectedCategories.contains(label);

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
