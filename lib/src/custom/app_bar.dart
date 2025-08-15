import 'package:flutter/material.dart';
import 'package:sharing_items/const/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final TextEditingController? searchController;
  final bool showSearch;

  const CustomAppBar({
    super.key,
    required this.title,
    this.searchController,
    this.showSearch = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: pointColorWeak,
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
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.location_on),
          color: Colors.white,
          tooltip: '위치 설정',
          onPressed: () {
            //구글지도를 통해 위치설정 기능 구현하기
          },
        ),
      ],
    );
  }
}