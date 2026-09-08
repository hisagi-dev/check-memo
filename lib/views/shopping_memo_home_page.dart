import 'package:flutter/material.dart';
import '../models/memo_document.dart';
import '../viewmodels/shopping_memo_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';

class ShoppingMemoHomePage extends StatefulWidget {
  final MemoDocument memoDoc;
  final HomeViewModel homeViewModel;

  const ShoppingMemoHomePage({
    super.key,
    required this.memoDoc,
    required this.homeViewModel,
  });

  @override
  State<ShoppingMemoHomePage> createState() => _ShoppingMemoHomePageState();
}

class _ShoppingMemoHomePageState extends State<ShoppingMemoHomePage> {
  late final ShoppingMemoViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ShoppingMemoViewModel(
      memoDoc: widget.memoDoc,
      homeViewModel: widget.homeViewModel,
    );
    _viewModel.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeItems = _viewModel.activeItems;

    return Scaffold(
      appBar: AppBar(
        title: Text(_viewModel.memoTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _viewModel.textController,
                    decoration: const InputDecoration(
                      hintText: 'アイテムを追加...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onSubmitted: (_) => _viewModel.addItem(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _viewModel.addItem,
                  child: const Text('追加'),
                ),
              ],
            ),
          ),
          if (activeItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _viewModel.allChecked,
                        onChanged: _viewModel.toggleAllCheck,
                      ),
                      const Text('すべて選択', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _viewModel.completeAllActive,
                    icon: const Icon(Icons.done_all, size: 18),
                    label: const Text('一括完了（下へ送る）'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: activeItems.isEmpty
                ? const Center(
                    child: Text(
                      'メモは空です',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ReorderableListView.builder(
                    buildDefaultDragHandles: false, // 標準ハンドルを非表示にし、自前の1個のハンドルを使用
                    itemCount: activeItems.length,
                    onReorder: (oldIndex, newIndex) {
                      _viewModel.reorderActiveItems(oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final item = activeItems[index];
                      return Card(
                        key: ValueKey(item),
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: Checkbox(
                            value: item.isChecked,
                            onChanged: (val) => _viewModel.toggleItemCheck(item, val),
                          ),
                          title: Text(
                            item.text,
                            style: TextStyle(
                              decoration: item.isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                              color: item.isChecked ? Colors.grey : Colors.black,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () {
                                  if (!_viewModel.moveUncheckedOnComplete && !item.isChecked) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('チェックが入っていないため移動しません（設定で変更可能）'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                    return;
                                  }
                                  _viewModel.completeItem(item);
                                },
                                child: const Text('完了'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20),
                                onPressed: () => _viewModel.deleteItem(item),
                              ),
                              // 1個のドラッグハンドル
                              ReorderableDragStartListener(
                                index: index,
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(Icons.drag_handle, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          _buildBottomTabSheet(context),
        ],
      ),
    );
  }

  Widget _buildBottomTabSheet(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showCompletedBottomSheet(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.archive_outlined, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '完了済み / ストック (${_viewModel.completedCount})',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
              ),
              const Icon(Icons.keyboard_arrow_up, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showCompletedBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final completedItems = _viewModel.completedItems;

            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.3,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '完了したアイテム（ストック）',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      if (completedItems.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _viewModel.allCompletedChecked,
                                    onChanged: (val) {
                                      _viewModel.toggleAllCompletedCheck(val);
                                      setModalState(() {});
                                    },
                                  ),
                                  const Text('すべて選択', style: TextStyle(fontSize: 14)),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _viewModel.uncompleteAllCompleted();
                                  setModalState(() {});
                                },
                                icon: const Icon(Icons.unarchive_outlined, size: 18),
                                label: const Text('一括でリストに戻す'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Divider(),
                      Expanded(
                        child: completedItems.isEmpty
                            ? const Center(child: Text('アイテムはありません'))
                            : ReorderableListView.builder(
                                buildDefaultDragHandles: false, // ストック側も標準ハンドルをオフ
                                itemCount: completedItems.length,
                                onReorder: (oldIndex, newIndex) {
                                  _viewModel.reorderCompletedItems(oldIndex, newIndex);
                                  setModalState(() {});
                                },
                                itemBuilder: (context, index) {
                                  final item = completedItems[index];
                                  return ListTile(
                                    key: ValueKey(item),
                                    leading: Checkbox(
                                      value: item.isChecked,
                                      onChanged: (val) {
                                        _viewModel.toggleItemCheck(item, val);
                                        setModalState(() {});
                                      },
                                    ),
                                    title: Text(
                                      item.text,
                                      style: TextStyle(
                                        decoration: (_viewModel.strikeThroughOnCompleted && item.isChecked)
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                        color: item.isChecked ? Colors.grey : Colors.black87,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            _viewModel.uncompleteItem(item);
                                            setModalState(() {});
                                          },
                                          child: const Text('リストに戻す'),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 20),
                                          onPressed: () {
                                            _viewModel.deleteItem(item);
                                            setModalState(() {});
                                          },
                                        ),
                                        // ストック側の1個のドラッグハンドル
                                        ReorderableDragStartListener(
                                          index: index,
                                          child: const Padding(
                                            padding: EdgeInsets.all(4.0),
                                            child: Icon(Icons.drag_handle, color: Colors.grey),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool followGlobal = !_viewModel.isCustomSettings;
            bool strike = _viewModel.strikeThroughOnCompleted;
            bool keep = _viewModel.keepCheckStateOnMove;
            bool move = _viewModel.moveUncheckedOnComplete;

            return AlertDialog(
              title: const Text('このメモの設定'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('全体のデフォルト設定に従う'),
                    subtitle: const Text('ONにするとホーム画面の全体設定が自動で反映されます'),
                    value: followGlobal,
                    onChanged: (bool value) {
                      setDialogState(() {
                        _viewModel.setFollowGlobalSettings(value);
                        followGlobal = !_viewModel.isCustomSettings;
                        strike = _viewModel.strikeThroughOnCompleted;
                        keep = _viewModel.keepCheckStateOnMove;
                        move = _viewModel.moveUncheckedOnComplete;
                      });
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('完了済みに取り消し線を引く'),
                    value: strike,
                    onChanged: followGlobal
                        ? null
                        : (val) {
                            setDialogState(() => strike = val);
                            _viewModel.updateCustomSettingField(strikeThroughOnCompleted: val);
                          },
                  ),
                  SwitchListTile(
                    title: const Text('移動時にチェック状態を維持する'),
                    value: keep,
                    onChanged: followGlobal
                        ? null
                        : (val) {
                            setDialogState(() => keep = val);
                            _viewModel.updateCustomSettingField(keepCheckStateOnMove: val);
                          },
                  ),
                  SwitchListTile(
                    title: const Text('未チェックも一括完了で移動する'),
                    value: move,
                    onChanged: followGlobal
                        ? null
                        : (val) {
                            setDialogState(() => move = val);
                            _viewModel.updateCustomSettingField(moveUncheckedOnComplete: val);
                          },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('閉じる'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}