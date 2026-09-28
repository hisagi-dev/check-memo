import 'package:flutter_test/flutter_test.dart';
import 'package:memo_app/models/memo_document.dart';

void main() {
  test('pinned state is serialized and restored', () {
    final memo = MemoDocument(
      id: 'memo-id',
      title: 'Pinned memo',
      items: [],
      sortOrder: 2,
      isPinned: true,
    );

    final restored = MemoDocument.fromMap(memo.toMap(), memo.id);

    expect(restored.isPinned, isTrue);
    expect(restored.sortOrder, 2);
  });

  test('legacy memo data defaults to unpinned', () {
    final memo = MemoDocument.fromMap({'title': 'Legacy memo'}, 'memo-id');

    expect(memo.isPinned, isFalse);
  });
}
