import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/memo_document.dart';
import 'home_viewmodel.dart';

class ShoppingMemoViewModel extends ChangeNotifier {
  final MemoDocument memoDoc;
  final HomeViewModel homeViewModel;
  final TextEditingController textController = TextEditingController();

  ShoppingMemoViewModel({required this.memoDoc, required this.homeViewModel});

  MemoSettings get effectiveSettings => memoDoc.customSettings ?? homeViewModel.globalSettings;

  bool get strikeThroughOnCompleted => effectiveSettings.strikeThroughOnCompleted;
  bool get keepCheckStateOnMove => effectiveSettings.keepCheckStateOnMove;
  bool get moveUncheckedOnComplete => effectiveSettings.moveUncheckedOnComplete;

  bool get isCustomSettings => memoDoc.customSettings != null;

  void setFollowGlobalSettings(bool followGlobal) {
    if (followGlobal) {
      memoDoc.customSettings = null;
    } else {
      memoDoc.customSettings = MemoSettings(
        strikeThroughOnCompleted: homeViewModel.globalSettings.strikeThroughOnCompleted,
        keepCheckStateOnMove: homeViewModel.globalSettings.keepCheckStateOnMove,
        moveUncheckedOnComplete: homeViewModel.globalSettings.moveUncheckedOnComplete,
      );
    }
    notifyListeners();
  }

  void updateCustomSettingField({
    bool? strikeThroughOnCompleted,
    bool? keepCheckStateOnMove,
    bool? moveUncheckedOnComplete,
  }) {
    if (memoDoc.customSettings == null) {
      memoDoc.customSettings = MemoSettings(
        strikeThroughOnCompleted: homeViewModel.globalSettings.strikeThroughOnCompleted,
        keepCheckStateOnMove: homeViewModel.globalSettings.keepCheckStateOnMove,
        moveUncheckedOnComplete: homeViewModel.globalSettings.moveUncheckedOnComplete,
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
    notifyListeners();
  }

  List<MemoItem> get items => memoDoc.items;
  List<MemoItem> get activeItems => memoDoc.items.where((item) => !item.isCompleted).toList();
  List<MemoItem> get completedItems => memoDoc.items.where((item) => item.isCompleted).toList();

  bool get allChecked => activeItems.isNotEmpty && activeItems.every((i) => i.isChecked);
  
  bool get allCompletedChecked => completedItems.isNotEmpty && completedItems.every((i) => i.isChecked);

  int get completedCount => completedItems.length;
  String get memoTitle => memoDoc.title;

  void addItem() {
    if (textController.text.trim().isEmpty) return;
    memoDoc.items.add(MemoItem(text: textController.text.trim()));
    textController.clear();
    notifyListeners();
  }

  void deleteItem(MemoItem item) {
    memoDoc.items.remove(item);
    notifyListeners();
  }

  void toggleItemCheck(MemoItem item, bool? isChecked) {
    item.isChecked = isChecked ?? false;
    notifyListeners();
  }

  void toggleAllCheck(bool? isChecked) {
    final value = isChecked ?? false;
    for (var item in activeItems) {
      item.isChecked = value;
    }
    notifyListeners();
  }

  void toggleAllCompletedCheck(bool? isChecked) {
    final value = isChecked ?? false;
    for (var item in completedItems) {
      item.isChecked = value;
    }
    notifyListeners();
  }

  void completeItem(MemoItem item) {
    item.isCompleted = true;
    if (!keepCheckStateOnMove) {
      item.isChecked = false;
    }
    notifyListeners();
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
    notifyListeners();
  }

  void uncompleteItem(MemoItem item) {
    item.isCompleted = false;
    if (!keepCheckStateOnMove) {
      item.isChecked = false;
    }
    notifyListeners();
  }

  void uncompleteAllCompleted() {
    for (var item in completedItems) {
      item.isCompleted = false;
      if (!keepCheckStateOnMove) {
        item.isChecked = false;
      }
    }
    notifyListeners();
  }

  // ★ リスト（未完了）の並べ替えを反映
  void reorderActiveItems(int oldIndex, int newIndex) {
    final list = activeItems;
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    memoDoc.items = [...list, ...completedItems];
    notifyListeners();
  }

  // ★ ストック（完了済み）の並べ替えを反映
  void reorderCompletedItems(int oldIndex, int newIndex) {
    final list = completedItems;
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    memoDoc.items = [...activeItems, ...list];
    notifyListeners();
  }
}