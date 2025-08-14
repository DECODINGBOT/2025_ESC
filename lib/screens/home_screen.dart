import 'package:flutter/material.dart';
import 'package:sharing_items/src/custom/app_bar.dart';
import 'package:sharing_items/src/custom/bottom_nav.dart';

/// 홈페이지
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController itemController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "홈"),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: SingleChildScrollView(child: Text('body')),
      ),
      bottomNavigationBar: CustomBottomNav(),
    );
  }
}
