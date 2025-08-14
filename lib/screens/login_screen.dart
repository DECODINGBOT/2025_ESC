// CHANGED: 이메일 -> 아이디(username), Firebase 호출 → 백엔드 호출로 변경
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sharing_items/src/service/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // CHANGED: email -> username
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(builder: (context, authService, child) {
      final loggedIn = authService.isLoggedIn;
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: AppBar(
            centerTitle: true,
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                loggedIn
                    ? "${authService.username}님 안녕하세요 👋"
                    : "로그인 해주세요 🙂",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            toolbarHeight: 120.0,
            backgroundColor: const Color(0xFF213555),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // CHANGED: 아이디
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(hintText: "아이디"),
              ),
              // 비밀번호
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: "비밀번호"),
              ),
              const SizedBox(height: 40),
              // 버튼들
              _loginButtons(authService),
            ],
          ),
        ),
      );
    });
  }

  Widget _loginButtons(AuthService authService) {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        width: constraints.maxWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _signInButton(authService),
            const SizedBox(height: 12),
            _signUpButton(authService),
            const SizedBox(height: 100),
            _signInWithGoogle(), // UI 유지(백엔드 연동과 별개)
            const SizedBox(height: 12),
            _signInWithKakao(),  // UI 유지(백엔드 연동과 별개)
            const SizedBox(height: 12),
          ],
        ),
      );
    });
  }

  Widget _signInButton(AuthService authService) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF213555),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: const Text("로그인", style: TextStyle(fontSize: 24, color: Colors.white)),
        onPressed: () {
          authService.signInBackend(
            username: usernameController.text.trim(), // CHANGED
            password: passwordController.text,
            onSuccess: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("로그인 성공")));
              Navigator.pushReplacementNamed(context, '/home');
            },
            onError: (err) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
            },
          );
        },
      ),
    );
  }

  Widget _signUpButton(AuthService authService) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF213555),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: const Text("회원가입", style: TextStyle(fontSize: 24, color: Colors.white)),
        onPressed: () {
          authService.signUpBackend(
            username: usernameController.text.trim(),  // CHANGED
            password: passwordController.text,
            onSuccess: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("회원가입 성공")));
            },
            onError: (err) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
            },
          );
        },
      ),
    );
  }

  // 그대로 둡니다(백엔드 연동 범위 밖)
  Widget _signInWithGoogle() { /* ... 기존과 동일 ... */ 
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF5EFE7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/icons/google_logo.svg', height: 24),
            const SizedBox(width: 8),
            const Text('구글로 로그인 하기', style: TextStyle(fontSize: 24, color: Color(0xFF213555))),
          ],
        ),
        onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
      ),
    );
  }

  Widget _signInWithKakao() { /* ... 기존과 동일 ... */
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFEE500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/icons/kakao_logo.svg', height: 24),
            const SizedBox(width: 8),
            const Text('카카오로 로그인 하기', style: TextStyle(fontSize: 24, color: Color(0xFF213555))),
          ],
        ),
        onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
      ),
    );
  }
}
