import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/memo_document.dart';
import 'home_viewmodel.dart';

class ShoppingMemoViewModel extends ChangeNotifier {
  final MemoDocument memoDoc;
  final HomeViewModel homeViewModel; // 全体設定を参照するため保持
  final TextEditingController textController = TextEditingController();

  ShoppingMemoViewModel({required this.memoDoc, required this.homeViewModel});

  // 現在有効な設定を返す（個別設定があればそれを、なければ全体設定を返す）
  MemoSettings get effectiveSettings => memoDoc.customSettings ?? homeViewModel.globalSettings;

  bool get strikeThroughOnCompleted => effectiveSettings.strikeThroughOnCompleted;
  bool get keepCheckStateOnMove => effectiveSettings.keepCheckStateOnMove;
  bool get moveUncheckedOnComplete => effectiveSettings.moveUncheckedOnComplete;

  // このメモが独自の設定を持っているか（オーバーライド中か）
  bool get isCustomSettings => memoDoc.customSettings != null;

  // 「全体設定に連動させる」チェックボックスが変更されたとき
  void setFollowGlobalSettings(bool followGlobal) {
    if (followGlobal) {
      // 個別設定を破棄して全体設定に連動させる
      memoDoc.customSettings = null;
    } else {
      // 現在の全体設定をコピーして個別設定として保持（オーバーライド開始）
      memoDoc.customSettings = MemoSettings(
        strikeThroughOnCompleted: homeViewModel.globalSettings.strikeThroughOnCompleted,
        keepCheckStateOnMove: homeViewModel.globalSettings.keepCheckStateOnMove,
        moveUncheckedOnComplete: homeViewModel.globalSettings.moveUncheckedOnComplete,
      );
    }
    notifyListeners();
  }

  // 個別設定の各項目を変更する（自動的にオーバーライド状態になる）
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

  // 1個のアイテムを完了（ストックへ移動）させる
  void completeItem(MemoItem item) {
    item.isCompleted = true;
    
    // 設定がOFF（デフォルト）の場合はチェックを強制的に外す
    // 設定がONの場合は、現在のチェック状態をそのまま維持する
    if (!keepCheckStateOnMove) {
      item.isChecked = false;
    }
    notifyListeners();
  }

// 一括完了（ストックへ移動）
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

  // ストックから元のリストに戻す
  void uncompleteItem(MemoItem item) {
    item.isCompleted = false;
    
    // 設定がOFFの場合は、戻すときにもチェックを外す
    // 設定がONの場合は、ストックにあったときのチェック状態を維持して戻す
    if (!keepCheckStateOnMove) {
      item.isChecked = false;
    }
    notifyListeners();
  }
}