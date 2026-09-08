class MemoItem {
  String text;
  bool isChecked;
  bool isCompleted;

  MemoItem({
    required this.text,
    this.isChecked = false,
    this.isCompleted = false,
  });
}

// 共通の設定項目をまとめたクラス
class MemoSettings {
  bool strikeThroughOnCompleted; // 完了済みに取り消し線を引くか
  bool keepCheckStateOnMove;     // 移動時にチェック状態を維持するか
  bool moveUncheckedOnComplete;  // 未チェックも一括完了で移動するか

  MemoSettings({
    this.strikeThroughOnCompleted = true,
    this.keepCheckStateOnMove = false,
    this.moveUncheckedOnComplete = false,
  });

  // コピーを作る用（設定の複製）
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
  
  // 個別の設定。nullなら「全体設定（グローバル設定）に従う」
  MemoSettings? customSettings;

  MemoDocument({
    required this.id,
    required this.title,
    required this.items,
    this.customSettings,
  });

  // 個別設定がなければnull、あればカスタム設定を返す
  bool get isCustomSettings => customSettings != null;
}