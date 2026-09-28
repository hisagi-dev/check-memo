import '../models/memo_document.dart';

class MemoSearch {
  const MemoSearch();

  List<MemoDocument> filter(Iterable<MemoDocument> memos, String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return memos.toList(growable: false);

    return memos
        .where(
          (memo) =>
              memo.title.toLowerCase().contains(normalizedQuery) ||
              memo.items.any(
                (item) => item.text.toLowerCase().contains(normalizedQuery),
              ),
        )
        .toList(growable: false);
  }
}
