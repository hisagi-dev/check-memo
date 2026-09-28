import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/memo_document.dart';
import '../repositories/memo_repository.dart';
import '../services/memo_search.dart';

class HomeViewModel extends ChangeNotifier {
  final MemoRepository _repository;
  final MemoSearch _memoSearch = const MemoSearch();
  StreamSubscription<List<MemoDocument>>? _memosSubscription;

  MemoSettings globalSettings = MemoSettings(
    strikeThroughOnCompleted: true,
    keepCheckStateOnMove: false,
    moveUncheckedOnComplete: false,
  );

  List<MemoDocument> _memos = [];
  List<MemoDocument> get memos => _memos;
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  List<MemoDocument> get filteredMemos =>
      _memoSearch.filter(_memos, _searchQuery);
  String? _loadError;
  String? get loadError => _loadError;

  HomeViewModel({MemoRepository? repository})
    : _repository = repository ?? MemoRepository() {
    _listenToMemos();
  }

  // Firestore のリアルタイム更新を監視
  void _listenToMemos() {
    _memosSubscription = _repository.getMemosStream().listen(
      (memoList) {
        final indexedMemos = memoList.asMap().entries.toList();
        indexedMemos.sort((first, second) {
            final pinComparison = (second.value.isPinned ? 1 : 0)
                .compareTo(first.value.isPinned ? 1 : 0);
          if (pinComparison != 0) return pinComparison;

          final firstOrder = first.value.sortOrder ?? first.key;
          final secondOrder = second.value.sortOrder ?? second.key;
          final orderComparison = firstOrder.compareTo(secondOrder);
          return orderComparison != 0
              ? orderComparison
              : first.key.compareTo(second.key);
        });
        _memos = indexedMemos.map((entry) => entry.value).toList();
        _loadError = null;
        notifyListeners();
      },
      onError: (Object error, StackTrace stackTrace) {
        _loadError = error.toString();
        debugPrint('Failed to read memos from Firestore: $error');
        debugPrintStack(stackTrace: stackTrace);
        notifyListeners();
      },
    );
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

  void updateSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> toggleMemoPin(MemoDocument memo) async {
    final previousPinnedState = memo.isPinned;
    final previousMemos = List<MemoDocument>.from(_memos);
    memo.isPinned = !previousPinnedState;
    final indexedMemos = _memos.asMap().entries.toList();
    indexedMemos.sort((first, second) {
            final pinComparison = (second.value.isPinned ? 1 : 0)
                .compareTo(first.value.isPinned ? 1 : 0);
      if (pinComparison != 0) return pinComparison;
      final firstOrder = first.value.sortOrder ?? first.key;
      final secondOrder = second.value.sortOrder ?? second.key;
      return firstOrder.compareTo(secondOrder);
    });
    final updatedMemos = indexedMemos.map((entry) => entry.value).toList();
    _memos = updatedMemos;
    notifyListeners();

    try {
      await _repository.updateMemoDocument(memo);
    } catch (_) {
      memo.isPinned = previousPinnedState;
      _memos = previousMemos;
      notifyListeners();
      rethrow;
    }
  }

  Future<MemoDocument> addMemoDocument(String title) async {
    if (title.trim().isEmpty) {
      throw ArgumentError.value(title, 'title', 'タイトルを入力してください');
    }
    final sortOrder =
        _memos.isEmpty
            ? 0
            : _memos.indexed
                    .map((entry) => entry.$2.sortOrder ?? entry.$1)
                    .reduce(
                      (first, second) => first < second ? first : second,
                    ) -
                1;
    final newDoc = MemoDocument(
      id: '', // リポジトリ側で生成されるため空文字
      title: title.trim(),
      items: [],
      sortOrder: sortOrder,
    );
    await _repository.addMemoDocument(newDoc);
    return newDoc;
  }

  Future<void> reorderMemos(
    MemoDocument draggedMemo,
    MemoDocument targetMemo,
  ) async {
    final draggedIndex = _memos.indexOf(draggedMemo);
    final targetIndex = _memos.indexOf(targetMemo);
    if (draggedIndex < 0 || targetIndex < 0 || draggedIndex == targetIndex) {
      return;
    }

    final previousMemos = List<MemoDocument>.from(_memos);
    final previousOrders = {for (final memo in _memos) memo.id: memo.sortOrder};
    final reorderedMemos = List<MemoDocument>.from(_memos);
    final movedMemo = reorderedMemos.removeAt(draggedIndex);
    reorderedMemos.insert(targetIndex, movedMemo);
    _memos = reorderedMemos;
    for (var index = 0; index < _memos.length; index++) {
      _memos[index].sortOrder = index;
    }
    notifyListeners();

    try {
      await _repository.updateMemoOrder(_memos);
    } catch (_) {
      _memos = previousMemos;
      for (final memo in _memos) {
        memo.sortOrder = previousOrders[memo.id];
      }
      notifyListeners();
      rethrow;
    }
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
