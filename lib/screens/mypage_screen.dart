import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sharing_items/const/colors.dart';
import 'package:sharing_items/screens/write_screen.dart';
import 'package:sharing_items/screens/edit_myinfo_screen.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {

  // 텍스트 스타일
  TextStyle get _titleStyle => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  TextStyle get _bodyStyle => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );

  TextStyle get _detailStyle => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: Colors.black,
  );

  // --------- 상태: 내 정보(초기값은 예시) ---------
  String? profileImageUrl;
  String userId = '아이디';
  DateTime joinDate = DateTime(2025, 8, 14);
  String address = '주소';

  // 임시 데이터: 내가 쓴 글/대여내역
  final bool hasMyPosts = false;
  final List<RentalItem> myRentals = [];

  String _dateText(DateTime d) =>
      "${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        //backgroundColor: strong,
        backgroundColor: pointColorWeak,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '마이페이지',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "내 정보",
                style: TextStyle(color: pointColorStrong, fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              _buildMyInfoCard(
                context,
                profileImageUrl: profileImageUrl,
                userId: userId,
                joinedAt: _dateText(joinDate),
                address: address,
              ),
              const SizedBox(height: 20),

              _SectionHeader(
                title: '내가 쓴 글',
                trailing: TextButton(
                  onPressed: () => _onWriteTapped(context),
                  child: Row(
                    children: [
                      const Text(
                        '작성하기',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 4),
                      SvgPicture.asset(
                        'assets/icons/chevron-right.svg',
                        width: 16,
                        height: 16,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _MyPostsArea(
                hasPosts: hasMyPosts,
                bodyStyle: _bodyStyle,
                detailStyle: _detailStyle,
              ),

              const SizedBox(height: 24),
              const _SectionHeader(title: '대여 내역'),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myRentals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _RentalTile(item: myRentals[index]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------- 위젯들 ---------
  Widget _buildMyInfoCard(
    BuildContext context, {
    required String? profileImageUrl,
    required String userId,
    required String joinedAt,
    required String address,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: widgetbackgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: profileImageUrl == null
                ? Container(
                    width: 64,
                    height: 64,
                    color: Colors.white,
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color:pointColorStrong,
                    ),
                  )
                : Image.network(
                    profileImageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 16),

          // 텍스트 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userId,
                  style: _bodyStyle.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Text(joinedAt, style: _detailStyle)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(address, style: _detailStyle),
              ],
            ),
          ),
          const SizedBox(width: 8),

          SizedBox(
            height: 36,
            child: OutlinedButton(
              onPressed: () => _onEditTapped(context),
              style: OutlinedButton.styleFrom(
                backgroundColor:widgetbackgroundColor,
                foregroundColor:pointColorStrong,
                side: const BorderSide(color: pointColorStrong, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                textStyle: const TextStyle(
                  fontSize: 14,
                ),
              ),
              child: const Text('수정'),
            ),
          ),
        ],
      ),
    );
  }

  // --------- 액션들 ---------
  Future<void> _onEditTapped(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditMyInfoScreen(
          initialUserId: userId,
          initialJoinDate: joinDate,
          initialAddress: address,
          // 필요 시 아래도 전달
          // initialDetailAddress: detailAddress,
          // initialPhone: phone,
          // initialAbout: about,
          initialProfileImageUrl: profileImageUrl,
        ),
      ),
    );

    if (!mounted) return;
    if (result != null && result is Map) {
      setState(() {
        userId = (result['userId'] as String?) ?? userId;
        address = (result['address'] as String?) ?? address;
        profileImageUrl =
            (result['profileImageUrl'] as String?) ?? profileImageUrl;

        final iso = result['joinDate'] as String?;
        if (iso != null) {
          try {
            joinDate = DateTime.parse(iso);
          } catch (_) {}
        }
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('정보가 저장되었습니다.')));
    }
  }

  void _onWriteTapped(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WriteScreen()),
    );
  }
}

// ================== 보조 위젯들 ==================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: pointColorStrong,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _MyPostsArea extends StatelessWidget {
  const _MyPostsArea({
    required this.hasPosts,
    required this.bodyStyle,
    required this.detailStyle,
  });

  final bool hasPosts;
  final TextStyle bodyStyle;
  final TextStyle detailStyle;

  @override
  Widget build(BuildContext context) {
    if (!hasPosts) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: widgetbackgroundColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text(
          '아직 작성한 글이 없습니다.',
          style: TextStyle(
            fontSize: 16,
            color: pointColorStrong,
          ),
        ),
      );
    }

    final items = List.generate(3, (i) => '내 글 제목 ${i + 1}');
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index], style: bodyStyle),
            subtitle: Text('상세 보기', style: detailStyle),
            trailing: const Icon(
              Icons.chevron_right,
              color: pointColorStrong,
            ),
            onTap: () {},
          );
        },
      ),
    );
  }
}

class _RentalTile extends StatelessWidget {
  const _RentalTile({required this.item});
  final RentalItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widgetbackgroundColor,
        borderRadius: BorderRadius.circular(18),
        // border: Border.all(color: _MyPageScreenState.weak.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 56,
            height: 56,
            color: Colors.white,
            child: Icon(
              item.thumbnail,
              size: 32,
              color: pointColorWeak,
            ),
          ),
        ),
        title:
            const SizedBox.shrink() == null // just to keep const warning away
            ? null
            : Text(
                item.title,
                style: const TextStyle(
                  fontSize: 16,
                  color: pointColorStrong,
                  fontWeight: FontWeight.w700,
                ),
              ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              '대여기간  ${item.period}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '가격  ${item.price}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}

class RentalItem {
  final String title;
  final String period;
  final String price;
  final IconData thumbnail;

  RentalItem({
    required this.title,
    required this.period,
    required this.price,
    required this.thumbnail,
  });
}
