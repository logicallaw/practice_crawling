import 'package:flutter/material.dart';
import 'package:inha_notice/fonts/font.dart';
import 'package:inha_notice/screens/web_page.dart';
import 'package:inha_notice/themes/theme.dart';

/// **NoticeListTile**
/// 이 클래스는 공지사항 하나에 대한 정보를 출력하는 클래스입니다.
class NoticeListTile extends StatefulWidget {
  final Map<String, dynamic> notice;
  final bool isRead;
  final bool isBookmarked;
  final void Function(String noticeId) markNoticeAsRead;
  final Future<void> Function(Map<String, dynamic>) toggleBookmark;

  const NoticeListTile({
    super.key,
    required this.notice,
    required this.isRead,
    required this.isBookmarked,
    required this.markNoticeAsRead,
    required this.toggleBookmark,
  });

  @override
  State<NoticeListTile> createState() => _NoticeListTileState();
}

class _NoticeListTileState extends State<NoticeListTile> {
  @override
  void initState() {
    super.initState();
  }

  /// **사파리 웹 페이지를 띄우는 함수**
  Future<void> navigateToWebPage(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebPage(
          url: widget.notice['link'] ?? Font.kEmptyString,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 읽은 공지면 readTextColor, 읽지 않은 공지면 기본 색상을 표시
    final textColor = widget.isRead
        ? Theme.of(context).readTextColor
        : Theme.of(context).textTheme.bodyMedium?.color ??
            Theme.of(context).defaultColor;
    // 공지사항 제목
    final title = widget.notice.containsKey('title')
        ? widget.notice['title'] ?? '제목이 없는 게시글입니다'
        : '제목이 없는 게시글입니다';
    // 공지사항 날짜
    final date =
        widget.notice.containsKey('date') ? widget.notice['date'] ?? '' : '';
    // 공지사항 조회수
    final access =
        widget.notice.containsKey('access') ? widget.notice['access'] : null;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).noticeBorderColor,
                width: 1.0,
              ),
              top: BorderSide.none,
              left: BorderSide.none,
              right: BorderSide.none,
            ),
          ),
        ),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            widget.markNoticeAsRead(widget.notice['id'].toString());
            if (mounted) {
              await navigateToWebPage(context);
            }
          },
          child: ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: Font.kDefaultFont,
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                if (widget.notice.containsKey('body') &&
                    widget.notice['body'] != null)
                  Text(
                    widget.notice['body'],
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: Font.kDefaultFont,
                      fontSize: 14.0,
                      fontWeight: FontWeight.normal,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
              ],
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (widget.notice['date'] != null)
                        Text(
                          date,
                          style: TextStyle(
                            fontFamily: Font.kDefaultFont,
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal,
                            color: textColor.withOpacity(0.6),
                          ),
                        ),
                      const SizedBox(width: 5),
                      if (widget.notice['access'] != null)
                        Text(
                          '조회 $access',
                          style: TextStyle(
                            fontFamily: Font.kDefaultFont,
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal,
                            color: textColor.withOpacity(0.6),
                          ),
                        ),
                    ],
                  ),
                ),
                // 북마크 아이콘 정의
                IconButton(
                  icon: Icon(
                    widget.isBookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: widget.isBookmarked ? Colors.yellow : Colors.grey,
                  ),
                  onPressed: () async {
                    if (widget.notice.containsKey('id') &&
                        widget.notice['id'] != null) {
                      await widget.toggleBookmark(widget.notice);
                    }
                  },
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
