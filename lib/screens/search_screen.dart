import 'package:flutter/material.dart';
import 'package:sharing_items/const/Colors.dart';
import 'package:sharing_items/screens/home_screen.dart';
import 'package:sharing_items/screens/item_info.dart';

/// ※ 이미 프로젝트에 있는 위젯이라고 하셔서 그대로 사용합니다.
/// class ItemInfo extends StatelessWidget {
///   final String category;
///   final String title;
///   final String location;
///   final int price;
///   ...
/// }

class SearchScreen extends StatefulWidget {
  final TextEditingController? searchController;

  const SearchScreen({super.key, this.searchController});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // 카테고리 UI (필요시 사용)
  final List<Map<String, dynamic>> categories = const [
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
      "category": "자동차",
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
      "category": "자동차",
      "title": "차량용 핸드폰 거치대",
      "location": "서울 동작구",
      "price": 10000,
    },
  ];

  late List<Map<String, dynamic>> _results;

  @override
  void initState() {
    super.initState();
    _internalController = TextEditingController();
    _results = List<Map<String, dynamic>>.from(_allItems);
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    // 외부에서 넘겨준 컨트롤러는 dispose 하지 않음
    if (widget.searchController == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _controller.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _results = List<Map<String, dynamic>>.from(_allItems);
      } else {
        _results = _allItems.where((item) {
          final title = (item['title'] as String).toLowerCase();
          return title.contains(q); // 제목에 검색어 포함 여부
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _controller.clear(); // listener가 알아서 전체 목록으로 되돌림
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(115),
        child: AppBar(
          backgroundColor: pointColorWeak,
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 40),
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
      body: Column(
        children: [
          _buildResultArea(),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 1),
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
            "검색 결과 ${_results.length}개",
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

// class SelectCategory extends StatefulWidget {

//   const SelectCategory({
//     super.key,
//   });

//   @override
//   State<SelectCategory> createState() => _SelectCategoryState();
// }

// class _SelectCategoryState extends State<SelectCategory> {
//   late bool isLiked;

//   @override
//   void initState() {

//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container()
//   }
// }