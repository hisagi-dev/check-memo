import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/memo_document.dart';
import '../../viewmodels/shopping_memo_viewmodel.dart';
import 'components/completed_bottom_sheet.dart';
import 'components/memo_settings_dialog.dart';

class ShoppingMemoHomePage extends StatefulWidget {
  final MemoDocument memoDoc;
  final MemoSettings globalSettings;

  const ShoppingMemoHomePage({
    super.key,
    required this.memoDoc,
    required this.globalSettings,
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
      globalSettings: widget.globalSettings,
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
      backgroundColor: AppConstants.editScreenBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.editScreenBackgroundColor,
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
            padding: const EdgeInsets.all(AppConstants.paddingNormal),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _viewModel.textController,
                    decoration: const InputDecoration(
                      hintText: AppConstants.hintAddItem,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingNormal,
                        vertical: AppConstants.paddingMedium,
                      ),
                    ),
                    onSubmitted: (_) => _viewModel.addItem(),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                ElevatedButton(
                  onPressed: _viewModel.addItem,
                  child: const Text(AppConstants.labelAdd),
                ),
              ],
            ),
          ),
          if (activeItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge,
                vertical: AppConstants.paddingSmall,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _viewModel.allChecked,
                        onChanged: _viewModel.toggleAllCheck,
                      ),
                      const Text(
                        AppConstants.labelSelectAll,
                        style: TextStyle(fontSize: AppConstants.fontSizeSmall),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _viewModel.completeAllActive,
                    icon: const Icon(Icons.done_all, size: AppConstants.iconSizeSmall),
                    label: const Text(AppConstants.labelBulkComplete),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingNormal,
                        vertical: AppConstants.paddingMedium,
                      ),
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
                      AppConstants.textEmptyMemo,
                      style: TextStyle(
                        color: AppConstants.textColorGrey,
                        fontSize: AppConstants.fontSizeNormal,
                      ),
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
                        color: AppConstants.memoCardColor,
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingNormal,
                          vertical: AppConstants.paddingSmall,
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: item.isChecked,
                            onChanged: (val) => _viewModel.toggleItemCheck(item, val),
                          ),
                          title: Text(
                            item.text,
                            style: TextStyle(
                              decoration: item.isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                              color: item.isChecked ? AppConstants.textColorGrey : Colors.black,
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
                                        content: Text(AppConstants.snackBarUncheckedWarning),
                                        duration: Duration(seconds: AppConstants.snackBarDurationSeconds),
                                      ),
                                    );
                                    return;
                                  }
                                  _viewModel.completeItem(item);
                                },
                                child: const Text(AppConstants.labelComplete),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: AppConstants.iconSizeMedium,
                                ),
                                onPressed: () => _viewModel.deleteItem(item),
                              ),
                              ReorderableDragStartListener(
                                index: index,
                                child: const Padding(
                                  padding: EdgeInsets.all(AppConstants.paddingSmall),
                                  child: Icon(
                                    Icons.drag_handle,
                                    color: AppConstants.iconColorGrey,
                                  ),
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