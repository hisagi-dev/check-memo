import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../viewmodels/shopping_memo_viewmodel.dart';

class CompletedBottomSheet extends StatelessWidget {
  final ShoppingMemoViewModel viewModel;

  const CompletedBottomSheet({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.bottomSheetBgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.borderRadiusLarge)),
        boxShadow: [
          BoxShadow(
            color: AppConstants.shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showCompletedBottomSheetModal(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingNormal,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.archive_outlined, color: AppConstants.iconColorGrey),
                  const SizedBox(width: AppConstants.paddingMedium),
                  Text(
                    '完了済み / ストック (${viewModel.completedCount})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textColorGrey,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.keyboard_arrow_up, color: AppConstants.iconColorGrey),
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
              initialChildSize: AppConstants.bottomSheetInitialSize,
              minChildSize: AppConstants.bottomSheetMinSize,
              maxChildSize: AppConstants.bottomSheetMaxSize,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Column(
                    children: [
                      Container(
                        width: AppConstants.sheetHandleWidth,
                        height: AppConstants.sheetHandleHeight,
                        decoration: BoxDecoration(
                          color: AppConstants.handleColor,
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingNormal),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '完了したアイテム（ストック）',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeNormal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      if (completedItems.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
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
                                  const Text(
                                    AppConstants.labelSelectAll,
                                    style: TextStyle(fontSize: AppConstants.fontSizeSmall),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  viewModel.uncompleteAllCompleted();
                                  setModalState(() {});
                                },
                                icon: const Icon(Icons.unarchive_outlined, size: AppConstants.iconSizeSmall),
                                label: const Text(AppConstants.labelBulkRestore),
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
                      const Divider(),
                      Expanded(
                        child: completedItems.isEmpty
                            ? const Center(child: Text(AppConstants.textEmptyCompleted))
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
                                        color: item.isChecked
                                            ? AppConstants.textColorGrey
                                            : AppConstants.textColorDark,
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
                                          child: const Text(AppConstants.labelRestoreToList),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            size: AppConstants.iconSizeMedium,
                                          ),
                                          onPressed: () {
                                            viewModel.deleteItem(item);
                                            setModalState(() {});
                                          },
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