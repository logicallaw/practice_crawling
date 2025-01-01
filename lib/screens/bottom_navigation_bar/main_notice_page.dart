import 'package:flutter/material.dart';

import '../left_notice.dart';
import '../right_notice.dart';

class MainNoticePage extends StatelessWidget {
  const MainNoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 두 개의 탭
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF222222), // AppBar 배경색
          title: const Align(
            alignment: Alignment.centerLeft, // 제목을 왼쪽 정렬
            child: Text(
              '인하공유',
              style: TextStyle(
                color: Color(0xFFBAB6B6), // 제목 글자 색상 BAB6B6
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              color: const Color(0xFFBAB6B6), // 알림 버튼 색상
              onPressed: () {
                // 알림 버튼 동작 추가
                print('알림 버튼 클릭됨');
              },
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFF12B8FF), // 탭 선택 시 하단 표시줄 색상
            labelColor: Color(0xFF12B8FF), // 선택된 탭 텍스트 색상 12B8FF
            unselectedLabelColor: Color(0xFFBAB6B6), // 선택되지 않은 탭 텍스트 색상 BAB6B6
            tabs: [
              Tab(text: '학사'),
              Tab(text: '학과'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            LeftNoticePage(), // 왼쪽 탭
            RightNoticePage(), // 오른쪽 탭
          ],
        ),
      ),
    );
  }
}