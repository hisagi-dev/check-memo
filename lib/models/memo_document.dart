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

  Map toMap() {
    return {
      'strikeThroughOnCompleted': strikeThroughOnCompleted,
      'keepCheckStateOnMove': keepCheckStateOnMove,
      'moveUncheckedOnComplete': moveUncheckedOnComplete,
    };
  }

  factory MemoSettings.fromMap(Map map) {
    return MemoSettings(
      strikeThroughOnCompleted: map['strikeThroughOnCompleted'] ?? true,
      keepCheckStateOnMove: map['keepCheckStateOnMove'] ?? false,
      moveUncheckedOnComplete: map['moveUncheckedOnComplete'] ?? false,
    );
  }
}

class MemoDocument {
  String id;
  String title;
  List items;
  MemoSettings? customSettings;

  MemoDocument({
    required this.id,
    required this.title,
    required this.items,
    this.customSettings,
  });

  bool get isCustomSettings => customSettings != null;

  Map toMap() {
    return {
      'id': id,
      'title': title,
      'items': items.map((item) => item.toMap()).toList(),
      'customSettings': customSettings?.toMap(),
    };
  }

  factory MemoDocument.fromMap(Map map, String docId) {
    return MemoDocument(
      id: docId,
      title: map['title'] ?? '',
      items: (map['items'] as List?)
              ?.map((item) => MemoItem.fromMap(item as Map))
              .toList() ??
          [],
      customSettings: map['customSettings'] != null
          ? MemoSettings.fromMap(map['customSettings'] as Map)
          : null,
    );
  }
}