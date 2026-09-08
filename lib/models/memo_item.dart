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