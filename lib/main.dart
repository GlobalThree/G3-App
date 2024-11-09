import 'package:flutter/material.dart';

import 'presentation/pages/main_page.dart';

void main() async {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          // 사용자가 설정한 OS의 텍스트 크기를 무시
          textScaler: TextScaler.noScaling,
        ),
        child: MainPage(),
      ),
    );
  }
}
