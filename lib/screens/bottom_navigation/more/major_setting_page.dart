import 'package:flutter/material.dart';
import 'package:inha_notice/firebase/firebase_service.dart';
import 'package:inha_notice/fonts/font.dart';
import 'package:inha_notice/screens/bottom_navigation/more/major_utils.dart';
import 'package:inha_notice/themes/theme.dart';
import 'package:inha_notice/utils/shared_prefs/shared_prefs_manager.dart';
import 'package:inha_notice/widgets/themed_app_bar.dart';
import 'package:logger/logger.dart';

class MajorSettingPage extends StatefulWidget {
  const MajorSettingPage({super.key});

  @override
  State<MajorSettingPage> createState() => _MajorSettingPageState();
}

class _MajorSettingPageState extends State<MajorSettingPage> {
  final Logger logger = Logger();
  final TextEditingController _searchController = TextEditingController();
  Map<String, Map<String, String>> _filteredMajorGroups =
      MajorUtils.majorGroups;
  List<String> _filteredMajors = [];
  String? _currentMajor; // 한글 학과명
  String? _currentMajorKey; // 영문 학과명
  bool _isProcessing = false;

  String? get currentMajorKey => _currentMajorKey;

  @override
  void initState() {
    super.initState();
    _loadMajorPreference();
  }

  /// 저장된 나의 학과 설정 불러오기
  Future<void> _loadMajorPreference() async {
    setState(() {
      _currentMajorKey = SharedPrefsManager().getMajorKey();
      if (_currentMajorKey != null) {
        _currentMajor = MajorUtils.translateToKorean(_currentMajorKey);
      }
    });
  }

  /// 사용자 입력에 따른 학과를 필터링
  void _filterMajors(String query) {
    if (query.isEmpty) {
      if (_filteredMajorGroups != MajorUtils.majorGroups) {
        setState(() {
          _filteredMajorGroups = MajorUtils.majorGroups;
          _filteredMajors = [];
        });
      }
      return;
    }

    final List<String> filteredMajors = [
      for (var group in MajorUtils.majorGroups.values)
        for (var major in group.keys)
          if (major.contains(query)) major,
    ];

    setState(() {
      _filteredMajorGroups = {}; // 검색 시 단과대학 제거
      _filteredMajors = filteredMajors;
    });
  }

  /// 학과 선택 핸들러
  Future<void> _handleMajorSelection(String major) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _showLoadingDialog();
    });

    String newMajorKey = MajorUtils.translateToEnglish(major);

    try {
      await SharedPrefsManager().setMajorKey(currentMajorKey, newMajorKey);

      final isMajorNotificationOn =
          SharedPrefsManager().getMajorNotificationOn();
      if (isMajorNotificationOn) {
        await FirebaseService().updateMajorSubscription();
      }
      _showSnackbar('$major로 설정되었습니다!');
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      logger.e('❌ Error saving major: $e');
      _showSnackbar('저장 중 오류가 발생했습니다. 다시 시도해주세요!');
    } finally {
      _dismissLoadingDialog();
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 사용자가 닫을 수 없도록 설정
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColorLight,
            ),
          ),
        );
      },
    );
  }

  /// 다이얼로그 닫기
  void _dismissLoadingDialog() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontFamily: Font.kDefaultFont,
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Theme.of(context).snackBarTextColor,
          ),
        ),
        backgroundColor: Theme.of(context).snackBarBackgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ThemedAppBar(title: '학과 설정', titleSize: 20, isCenter: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_currentMajor != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  '현재 학과: $_currentMajor',
                  style: TextStyle(
                      fontFamily: Font.kDefaultFont,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color ??
                          Theme.of(context).defaultColor),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  '학과를 설정해주세요!',
                  style: TextStyle(
                      fontFamily: Font.kDefaultFont,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color ??
                          Theme.of(context).defaultColor),
                ),
              ),
            TextField(
              controller: _searchController,
              onChanged: _filterMajors,
              decoration: InputDecoration(
                labelText: '학과 검색',
                labelStyle: TextStyle(
                  fontFamily: Font.kDefaultFont,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Theme.of(context).hintColor,
                ),
                filled: false,
                prefixIcon: Icon(Icons.search,
                    color: Theme.of(context).iconTheme.color),
                // 검색 아이콘 추가
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).boxBorderColor,
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 2.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredMajors.isNotEmpty
                  ? ListView.builder(
                      itemCount: _filteredMajors.length,
                      itemBuilder: (context, index) {
                        final major = _filteredMajors[index];
                        return ListTile(
                          title: Text(major),
                          onTap: () async {
                            await _handleMajorSelection(major);
                          },
                        );
                      },
                    )
                  : ListView(
                      children: _filteredMajorGroups.entries.map((entry) {
                        return Theme(
                            data: Theme.of(context).copyWith(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                            ),
                            child: ExpansionTile(
                              title: Text(
                                entry.key,
                                style: TextStyle(
                                  fontFamily: Font.kDefaultFont,
                                  fontSize: 19,
                                  fontWeight: FontWeight.normal,
                                  color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color ??
                                      Theme.of(context).defaultColor,
                                ),
                              ),
                              children: entry.value.keys
                                  .map(
                                    (major) => ListTile(
                                      title: Text(major),
                                      onTap: () async {
                                        await _handleMajorSelection(major);
                                      },
                                    ),
                                  )
                                  .toList(),
                            ));
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
