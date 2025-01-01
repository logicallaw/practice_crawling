import 'package:flutter/material.dart';

import '../services/api.dart';
import 'notice.dart';

class RightNoticePage extends StatefulWidget {
  const RightNoticePage({super.key});

  @override
  State<RightNoticePage> createState() => _RightNoticePageState();
}

class _RightNoticePageState extends State<RightNoticePage> {
  final ApiService _apiService = ApiService();

  // 초기값 수정
  Map<String, dynamic> _notices = {'headline': [], 'general': [], 'pages': []};
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    try {
      final notices = await _apiService.fetchNoticesWithLinks(
          'https://cse.inha.ac.kr/cse/888/subview.do');
      setState(() {
        _notices = notices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
        decoration: const BoxDecoration(
        color: Color(0xEB292929), // 배경색 #292929, 투명도 92% (Alpha: EB)
    ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text('Error: $_error'))
          : ListView(
        children: [
          if (_notices['headline']!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Headline Notices',
                    style: TextStyle(
                        fontFamily: 'Pretendard', fontSize: 18, color: Colors.white),
                  ),
                ),
                ..._notices['headline']!.map((notice) {
                  return Container(
                      decoration: const BoxDecoration(
                        color: const Color(0xFF222222), // 배경색 #525050, 투명도 55% (Alpha: 8C)
                        border: const Border(
                          bottom: BorderSide(
                            color: Color(0x8C525050), // 하단 테두리 색상 #525050, 투명도 55% (Alpha: 8C)
                            width: 2.0, // 테두리 두께
                          ),
                        ),
                      ),
                  child: ListTile(
                    title: Text(
                      notice['title'] ?? 'No Title',
                      style: const TextStyle(
                          fontFamily: 'Pretendard', fontSize: 18, color: Colors.white
                      ), // 제목 글자색 하얀색
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoticePage(
                              url: notice['link'] ?? ''),
                        ),
                      );
                    },
                  ),
                  );
                }).toList(),
              ],
            ),
          if (_notices['general']!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'General Notices',
                    style: TextStyle(
                        fontFamily: 'Pretendard', fontSize: 18, color: Colors.white),
                  ),
                ),
                ..._notices['general']!.map((notice) {
                  return Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF292929),
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0x8C525050), // 하단 테두리 색상 #525050, 투명도 55% (Alpha: 8C)
                            width: 2.0, // 테두리 두께
                          ),
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          notice['title'] ?? 'No Title',
                          style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.normal, fontSize: 16, color: Colors.white),// 제목 글자색 하얀색
                        ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoticePage(
                              url: notice['link'] ?? ''),
                        ),
                      );
                    },
                  ),
                  );
                }).toList(),
              ],
            ),
        ],
      ),
    ),
    );
  }
}