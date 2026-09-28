import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/memo_document.dart';
import '../repositories/memo_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final MemoRepository _repository;
  StreamSubscription<List>? _memosSubscription;

  MemoSettings globalSettings = MemoSettings(
    strikeThroughOnCompleted: true,
    keepCheckStateOnMove: false,
    moveUncheckedOnComplete: false,
  );

  List _memos = [];
  List get memos => _memos;

  HomeViewModel({MemoRepository? repository})
      : _repository = repository ?? MemoRepository() {
    _listenToMemos();
  }

  // Firestore のリアルタイム更新を監視
  void _listenToMemos() {
    _memosSubscription = _repository.getMemosStream().listen((memoList) {
      _memos = memoList;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _memosSubscription?.cancel();
    super.dispose();
  }

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

  Future addMemoDocument(String title) async {
    if (title.trim().isEmpty) return;
    final newDoc = MemoDocument(
      id: '', // リポジトリ側で生成されるため空文字
      title: title.trim(),
      items: [],
    );
    await _repository.addMemoDocument(newDoc);
  }

  Future renameMemoDocument(MemoDocument doc, String newTitle) async {
    if (newTitle.trim().isEmpty) return;
    doc.title = newTitle.trim();
    await _repository.updateMemoDocument(doc);
  }

  Future deleteMemoDocument(MemoDocument doc) async {
    await _repository.deleteMemoDocument(doc.id);
  }
}