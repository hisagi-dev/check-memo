import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/memo_document.dart';
import '../models/memo_item.dart';
import '../repositories/memo_repository.dart';

class ShoppingMemoViewModel extends ChangeNotifier {
  final MemoDocument memoDoc;
  final MemoSettings globalSettings;
  final MemoRepository _repository;
  final TextEditingController textController = TextEditingController();

  ShoppingMemoViewModel({
    required this.memoDoc,
    required this.globalSettings,
    MemoRepository? repository,
  }) : _repository = repository ?? MemoRepository();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  MemoSettings get effectiveSettings => memoDoc.customSettings ?? globalSettings;

  bool get strikeThroughOnCompleted => effectiveSettings.strikeThroughOnCompleted;
  bool get keepCheckStateOnMove => effectiveSettings.keepCheckStateOnMove;
  bool get moveUncheckedOnComplete => effectiveSettings.moveUncheckedOnComplete;

  bool get isCustomSettings => memoDoc.customSettings != null;

  void _save() {
    _repository.updateMemoDocument(memoDoc);
    notifyListeners();
  }

  void setFollowGlobalSettings(bool followGlobal) {
    if (followGlobal) {
      memoDoc.customSettings = null;
    } else {
      memoDoc.customSettings = MemoSettings(
        strikeThroughOnCompleted: globalSettings.strikeThroughOnCompleted,
        keepCheckStateOnMove: globalSettings.keepCheckStateOnMove,
        moveUncheckedOnComplete: globalSettings.moveUncheckedOnComplete,
      );
    }
    _save();
  }

  void updateCustomSettingField({
    bool? strikeThroughOnCompleted,
    bool? keepCheckStateOnMove,
    bool? moveUncheckedOnComplete,
  }) {
    if (memoDoc.customSettings == null) {
      memoDoc.customSettings = MemoSettings(
        strikeThroughOnCompleted: globalSettings.strikeThroughOnCompleted,
        keepCheckStateOnMove: globalSettings.keepCheckStateOnMove,
        moveUncheckedOnComplete: globalSettings.moveUncheckedOnComplete,
      );
    }

    if (strikeThroughOnCompleted != null) {
      memoDoc.customSettings!.strikeThroughOnCompleted = strikeThroughOnCompleted;
    }
    if (keepCheckStateOnMove != null) {
      memoDoc.customSettings!.keepCheckStateOnMove = keepCheckStateOnMove;
    }
    if (moveUncheckedOnComplete != null) {
      memoDoc.customSettings!.moveUncheckedOnComplete = moveUncheckedOnComplete;
    }
    _save();
  }

  List get items => memoDoc.items;
  List get activeItems => memoDoc.items.where((item) => !item.isCompleted).toList();
  List get completedItems => memoDoc.items.where((item) => item.isCompleted).toList();

  bool get allChecked => activeItems.isNotEmpty && activeItems.every((i) => i.isChecked);
  bool get allCompletedChecked => completedItems.isNotEmpty && completedItems.every((i) => i.isChecked);

  int get completedCount => completedItems.length;
  String get memoTitle => memoDoc.title;

  void addItem() {
    if (textController.text.trim().isEmpty) return;
    memoDoc.items.add(MemoItem(text: textController.text.trim()));
    textController.clear();
    _save();
  }

  void deleteItem(MemoItem item) {
    memoDoc.items.remove(item);
    _save();
  }

  void toggleItemCheck(MemoItem item, bool? isChecked) {
    item.isChecked = isChecked ?? false;
    _save();
  }

  void toggleAllCheck(bool? isChecked) {
    final value = isChecked ?? false;
    for (var item in activeItems) {
      item.isChecked = value;
    }
    _save();
  }

  void toggleAllCompletedCheck(bool? isChecked) {
    final value = isChecked ?? false;
    for (var item in completedItems) {
      item.isChecked = value;
    }
    _save();
  }

  void completeItem(MemoItem item) {
    item.isCompleted = true;
    if (!keepCheckStateOnMove) {
      item.isChecked = false;
    }
    _save();
  }

  void completeAllActive() {
    for (var item in activeItems) {
      if (moveUncheckedOnComplete || item.isChecked) {
        item.isCompleted = true;
        if (!keepCheckStateOnMove) {
          item.isChecked = false;
        }
      }
    }
    _save();
  }

  void uncompleteItem(MemoItem item) {
    item.isCompleted = false;
    if (!keepCheckStateOnMove) {
      item.isChecked = false;
    }
    _save();
  }

  void uncompleteAllCompleted() {
    for (var item in completedItems) {
      item.isCompleted = false;
      if (!keepCheckStateOnMove) {
        item.isChecked = false;
      }
    }
    _save();
  }

  void reorderActiveItems(int oldIndex, int newIndex) {
    final list = activeItems;
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    memoDoc.items = [...list, ...completedItems];
    _save();
  }

  void reorderCompletedItems(int oldIndex, int newIndex) {
    final list = completedItems;
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    memoDoc.items = [...activeItems, ...list];
    _save();
  }
}