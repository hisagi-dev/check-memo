class MemoItem {
  String text;
  bool isChecked;
  bool isCompleted;

  MemoItem({
    required this.text,
    this.isChecked = false,
    this.isCompleted = false,
  });

  Map toMap() {
    return {
      'text': text,
      'isChecked': isChecked,
      'isCompleted': isCompleted,
    };
  }

  factory MemoItem.fromMap(Map map) {
    return MemoItem(
      text: map['text'] ?? '',
      isChecked: map['isChecked'] ?? false,
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}