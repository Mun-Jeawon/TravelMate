import 'package:flutter/material.dart';
import 'home.dart'; // home.dart 파일을 import 합니다.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter 네비게이션 바 예제',
      theme: ThemeData(
        primarySwatch: Colors.blue, // 앱의 기본 색상 테마
      ),
      home: const HomePage(), // 앱이 시작될 때 보여줄 첫 화면으로 HomePage를 지정합니다.
    );
  }
}