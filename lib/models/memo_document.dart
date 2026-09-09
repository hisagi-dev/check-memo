import 'memo_item.dart';

class MemoSettings {
  bool strikeThroughOnCompleted;
  bool keepCheckStateOnMove;
  bool moveUncheckedOnComplete;

  MemoSettings({
    this.strikeThroughOnCompleted = true,
    this.keepCheckStateOnMove = false,
    this.moveUncheckedOnComplete = false,
  });

  MemoSettings copyWith({
    bool? strikeThroughOnCompleted,
    bool? keepCheckStateOnMove,
    bool? moveUncheckedOnComplete,
  }) {
    return MemoSettings(
      strikeThroughOnCompleted: strikeThroughOnCompleted ?? this.strikeThroughOnCompleted,
      keepCheckStateOnMove: keepCheckStateOnMove ?? this.keepCheckStateOnMove,
      moveUncheckedOnComplete: moveUncheckedOnComplete ?? this.moveUncheckedOnComplete,
    );
  }
}

class MemoDocument {
  String id;
  String title;
  List<MemoItem> items;
  MemoSettings? customSettings;

  MemoDocument({
    required this.id,
    required this.title,
    required this.items,
    this.customSettings,
  });

  bool get isCustomSettings => customSettings != null;
}