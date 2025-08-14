import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A5A73), // 상단 파란색
        title: const Text("서울 성동구 사근동", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: Icon(Icons.menu, color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 검색창
            TextField(
              decoration: InputDecoration(
                hintText: "원하시는 물건을 검색해주세요",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 카테고리 카드
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.8,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  color: const Color(0xFFF3F0E8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: InkWell(
                    onTap: () {
                      // 카테고리 클릭 이벤트
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(category['icon'], size: 28, color: Colors.blueGrey),
                        const SizedBox(height: 6),
                        Text(category['label'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // 물건 등록하기 버튼
            
          ],
        ),
      ),
    );
  }
}
