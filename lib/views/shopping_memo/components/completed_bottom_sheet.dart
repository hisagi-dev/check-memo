import 'package:flutter/material.dart';
import '../../../viewmodels/shopping_memo_viewmodel.dart';

class CompletedBottomSheet extends StatelessWidget {
  final ShoppingMemoViewModel viewModel;

  const CompletedBottomSheet({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
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
        onTap: () => _showCompletedBottomSheetModal(context),
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
                    '完了済み / ストック (${viewModel.completedCount})',
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

  void _showCompletedBottomSheetModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final completedItems = viewModel.completedItems;

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
                                    value: viewModel.allCompletedChecked,
                                    onChanged: (val) {
                                      viewModel.toggleAllCompletedCheck(val);
                                      setModalState(() {});
                                    },
                                  ),
                                  const Text('すべて選択', style: TextStyle(fontSize: 14)),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  viewModel.uncompleteAllCompleted();
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
                                buildDefaultDragHandles: false,
                                itemCount: completedItems.length,
                                onReorder: (oldIndex, newIndex) {
                                  viewModel.reorderCompletedItems(oldIndex, newIndex);
                                  setModalState(() {});
                                },
                                itemBuilder: (context, index) {
                                  final item = completedItems[index];
                                  return ListTile(
                                    key: ValueKey(item),
                                    leading: Checkbox(
                                      value: item.isChecked,
                                      onChanged: (val) {
                                        viewModel.toggleItemCheck(item, val);
                                        setModalState(() {});
                                      },
                                    ),
                                    title: Text(
                                      item.text,
                                      style: TextStyle(
                                        decoration: (viewModel.strikeThroughOnCompleted && item.isChecked)
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
                                            viewModel.uncompleteItem(item);
                                            setModalState(() {});
                                          },
                                          child: const Text('リストに戻す'),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 20),
                                          onPressed: () {
                                            viewModel.deleteItem(item);
                                            setModalState(() {});
                                          },
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
}