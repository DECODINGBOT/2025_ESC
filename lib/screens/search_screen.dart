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
  // 카테고리 UI(아이콘/라벨) – 화면에 보여줄 때 사용(선택 패널에 라벨 사용 가능)

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

  /// 외부에서 controller가 없으면 내부에서 생성해서 사용
  late final TextEditingController _internalController;
  TextEditingController get _controller =>
      widget.searchController ?? _internalController;

  /// 예시 데이터 (실사용에선 API/DB 결과로 대체)
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

  // ---- 추가: 카테고리 패널 상태/애니메이션 & 선택 상태 ----
  bool _showCategoryPanel = false;
  late final AnimationController _arrowCtrl;
  final Set<String> _selectedCategories = {}; // 멀티 선택

  @override
  void initState() {
    super.initState();
    _internalController = TextEditingController();
    _results = List<Map<String, dynamic>>.from(_allItems);
    _controller.addListener(_applyFilters);

    // 화살표 회전 애니메이션
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

  // 검색어/카테고리 전체 필터 로직
  void _applyFilters() {
    final q = _controller.text.trim().toLowerCase();

    setState(() {
      _results = _allItems.where((item) {
        final title = (item['title'] as String).toLowerCase();
        final category = item['category'] as String;

        final matchQuery = q.isEmpty ? true : title.contains(q);
        final matchCategory = _selectedCategories.isEmpty
            ? true
            : _selectedCategories.contains(category);

        return matchQuery && matchCategory;
      }).toList();
    });
  }

  void _clearSearch() {
    _controller.clear();
  }

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
                    children: [
                      Text(
                        "검색",
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
          Column(
            children: [
              SizedBox(height: 50,),
              _buildResultArea(),
            ],
          ),
          Positioned(top: 0, left: 0, right: 0, child: _categoryTab()),
        ],
      ),
    );
  }

  Widget _categoryTab() {
    return Container(
      color: pointColorWeak,
      child: Column(
        children: [
          // 화살표 버튼
          Align(
            alignment: Alignment.center,
            child: IconButton(
              padding: const EdgeInsets.only(top: 6),
              tooltip: _showCategoryPanel ? "카테고리 접기" : "카테고리 펼치기",
              onPressed: _toggleCategoryPanel,
              icon: RotationTransition(
                turns: Tween<double>(begin: 0, end: 0.5).animate(_arrowCtrl),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: widgetbackgroundColor,
                ),
              ),
            ),
          ),

          // 펼쳐지는 카테고리 패널
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

  Widget _buildResultArea() {
    if (_results.isEmpty) {
      return const Center(
        child: Text("검색 결과가 없어요.", style: TextStyle(fontSize: 16)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 결과 개수 표시
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            "검색 결과 ${_results.length}개"
            "${_selectedCategories.isEmpty ? "" : " · 카테고리: ${_selectedCategories.join(", ")}"}",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final item = _results[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: ItemInfo(
                  category: item['category'] as String,
                  title: item['title'] as String,
                  location: item['location'] as String,
                  price: item['price'] as int,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
