import 'package:flutter/material.dart';
import '../../models/memo_document.dart';
import '../../viewmodels/shopping_memo_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import 'components/completed_bottom_sheet.dart';
import 'components/memo_settings_dialog.dart';

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
    _viewModel.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => MemoSettingsDialog(viewModel: _viewModel),
    );
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
                    buildDefaultDragHandles: false,
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
          CompletedBottomSheet(viewModel: _viewModel),
        ],
      ),
    );
  }
}