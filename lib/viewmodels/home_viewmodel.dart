import 'package:flutter/foundation.dart';
import '../models/memo_document.dart';
import '../models/memo_item.dart';

class HomeViewModel extends ChangeNotifier {
  MemoSettings globalSettings = MemoSettings(
    strikeThroughOnCompleted: true,
    keepCheckStateOnMove: false,
    moveUncheckedOnComplete: false,
  );

  final List<MemoDocument> _memos = [
    MemoDocument(
      id: '1',
      title: '今日のスーパー',
      items: [
        MemoItem(text: '牛乳'),
        MemoItem(text: '卵', isChecked: true),
      ],
    ),
  ];

  List<MemoDocument> get memos => _memos;

  void updateGlobalSettings({
    required bool strikeThroughOnCompleted,
    required bool keepCheckStateOnMove,
    required bool moveUncheckedOnComplete,
  }) {
    globalSettings.strikeThroughOnCompleted = strikeThroughOnCompleted;
    globalSettings.keepCheckStateOnMove = keepCheckStateOnMove;
    globalSettings.moveUncheckedOnComplete = moveUncheckedOnComplete;
    notifyListeners();
  }

  void addMemoDocument(String title) {
    if (title.trim().isEmpty) return;
    final newDoc = MemoDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      items: [],
    );
    _memos.add(newDoc);
    notifyListeners();
  }

  void renameMemoDocument(MemoDocument doc, String newTitle) {
    if (newTitle.trim().isEmpty) return;
    doc.title = newTitle.trim();
    notifyListeners();
  }

  void deleteMemoDocument(MemoDocument doc) {
    _memos.remove(doc);
    notifyListeners();
  }
}