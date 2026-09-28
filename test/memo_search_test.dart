import 'package:flutter_test/flutter_test.dart';
import 'package:memo_app/models/memo_document.dart';
import 'package:memo_app/models/memo_item.dart';
import 'package:memo_app/services/memo_search.dart';

void main() {
  const search = MemoSearch();
  final memos = [
    MemoDocument(
      id: '1',
      title: '食料品',
      items: [MemoItem(text: 'りんご'), MemoItem(text: '牛乳')],
    ),
    MemoDocument(
      id: '2',
      title: 'Daily supplies',
      items: [MemoItem(text: 'Toothbrush')],
    ),
    MemoDocument(id: '3', title: '旅行', items: []),
  ];

  test('blank query returns all memos in their original order', () {
    expect(search.filter(memos, '  ').map((memo) => memo.id), ['1', '2', '3']);
  });

  test('matches titles and item text without case sensitivity', () {
    expect(search.filter(memos, 'りんご').map((memo) => memo.id), ['1']);
    expect(search.filter(memos, 'tooth').map((memo) => memo.id), ['2']);
    expect(search.filter(memos, 'DAILY').map((memo) => memo.id), ['2']);
  });

  test('returns no memos when nothing matches', () {
    expect(search.filter(memos, '存在しない'), isEmpty);
  });
}
