import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../constants/app_constants.dart';
import '../viewmodels/home_viewmodel.dart';
import '../models/memo_document.dart';
import 'shopping_memo/shopping_memo_home_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State {
  final HomeViewModel _viewModel = HomeViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _showGlobalSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        bool strike = _viewModel.globalSettings.strikeThroughOnCompleted;
        bool keep = _viewModel.globalSettings.keepCheckStateOnMove;
        bool move = _viewModel.globalSettings.moveUncheckedOnComplete;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(AppConstants.dialogTitleGlobalSettings),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text(AppConstants.settingStrikeThroughTitle),
                    value: strike,
                    onChanged: (val) {
                      setDialogState(() => strike = val);
                      _viewModel.updateGlobalSettings(
                        strikeThroughOnCompleted: strike,
                        keepCheckStateOnMove: keep,
                        moveUncheckedOnComplete: move,
                      );
                    },
                  ),
                  SwitchListTile(
                    title: const Text(AppConstants.settingKeepCheckTitle),
                    value: keep,
                    onChanged: (val) {
                      setDialogState(() => keep = val);
                      _viewModel.updateGlobalSettings(
                        strikeThroughOnCompleted: strike,
                        keepCheckStateOnMove: keep,
                        moveUncheckedOnComplete: move,
                      );
                    },
                  ),
                  SwitchListTile(
                    title: const Text(AppConstants.settingMoveUncheckedTitle),
                    value: move,
                    onChanged: (val) {
                      setDialogState(() => move = val);
                      _viewModel.updateGlobalSettings(
                        strikeThroughOnCompleted: strike,
                        keepCheckStateOnMove: keep,
                        moveUncheckedOnComplete: move,
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(AppConstants.labelClose),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        String? errorMessage;
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text(AppConstants.dialogTitleNewMemo),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    onChanged: (_) => setDialogState(() => errorMessage = null),
                    decoration: const InputDecoration(
                      hintText: AppConstants.hintMemoTitle,
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(AppConstants.labelCancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = controller.text.trim();
                    if (title.isEmpty) {
                      setDialogState(() => errorMessage = 'タイトルを入力してください');
                      return;
                    }

                    Navigator.pop(dialogContext);
                    unawaited(_createMemo(title));
                  },
                  child: const Text(AppConstants.labelCreate),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _createMemo(String title) async {
    try {
      await _viewModel.addMemoDocument(title);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('作成できませんでした。通信状態を確認してください。')),
      );
    }
  }

  void _showRenameDialog(MemoDocument doc) {
    final controller = TextEditingController(text: doc.title);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppConstants.dialogTitleRename),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: AppConstants.hintNewMemoTitle,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppConstants.labelCancel),
            ),
            ElevatedButton(
              onPressed: () {
                _viewModel.renameMemoDocument(doc, controller.text);
                Navigator.pop(context);
              },
              child: const Text(AppConstants.labelSave),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.homeBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.homeBackgroundColor,
        title: const Text(AppConstants.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showGlobalSettingsDialog(context),
          ),
        ],
      ),
      body:
          _viewModel.memos.isEmpty
              ? const Center(child: Text(AppConstants.textEmptyHome))
              : LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = AppConstants.homeMemoCardWidth;
                  final spacing = AppConstants.gridCrossAxisSpacing;
                  final columnCount = ((constraints.maxWidth + spacing) /
                          (cardWidth + spacing))
                      .floor()
                      .clamp(1, _viewModel.memos.length);

                  return MasonryGridView.count(
                    padding: const EdgeInsets.all(AppConstants.paddingNormal),
                    crossAxisCount: columnCount,
                    mainAxisSpacing: AppConstants.gridMainAxisSpacing,
                    crossAxisSpacing: spacing,
                    itemCount: _viewModel.memos.length,
                    itemBuilder: (context, index) {
                      final doc = _viewModel.memos[index];
                      return _buildMemoCard(doc, cardWidth);
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMemoCard(MemoDocument doc, double cardWidth) {
    final previewItems = doc.items.take(
      AppConstants.homeMemoMaxPreviewItemCount,
    );
    final hiddenItemCount = doc.items.length - previewItems.length;

    return DragTarget<MemoDocument>(
      onAcceptWithDetails: (details) async {
        try {
          await _viewModel.reorderMemos(details.data, doc);
        } catch (_) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('メモの順番を保存できませんでした')));
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Card(
          margin: EdgeInsets.zero,
          color: AppConstants.memoCardColor,
          elevation: AppConstants.cardElevation,
          shape:
              candidateData.isNotEmpty
                  ? RoundedRectangleBorder(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusSmall,
                    ),
                  )
                  : null,
          child: SizedBox(
            width: cardWidth,
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ShoppingMemoHomePage(
                          memoDoc: doc,
                          globalSettings: _viewModel.globalSettings,
                        ),
                  ),
                );
                if (mounted) setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingNormal),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            doc.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: AppConstants.fontSizeNormal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Draggable<MemoDocument>(
                          data: doc,
                          feedback: Material(
                            color: Colors.transparent,
                            child: SizedBox(
                              width: cardWidth,
                              child: Card(
                                color: AppConstants.memoCardColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    AppConstants.paddingNormal,
                                  ),
                                  child: Text(
                                    doc.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          childWhenDragging: const Icon(
                            Icons.drag_indicator,
                            color: AppConstants.iconColorGrey,
                          ),
                          child: const Tooltip(
                            message: 'ドラッグして並べ替え',
                            child: Icon(
                              Icons.drag_indicator,
                              color: AppConstants.iconColorGrey,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            size: AppConstants.iconSizeSmall,
                          ),
                          onSelected: (value) {
                            if (value == 'rename') {
                              _showRenameDialog(doc);
                            } else if (value == 'delete') {
                              _viewModel.deleteMemoDocument(doc);
                            }
                          },
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: 'rename',
                                  child: Text(AppConstants.labelRename),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text(AppConstants.labelDelete),
                                ),
                              ],
                        ),
                      ],
                    ),
                    const Divider(),
                    ...previewItems.map<Widget>((item) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppConstants.paddingSmall,
                        ),
                        child: Text(
                          '• ${item.text}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color:
                                item.isCompleted
                                    ? AppConstants.textColorGrey
                                    : AppConstants.textColorDark,
                            decoration:
                                item.isChecked
                                    ? TextDecoration.lineThrough
                                    : null,
                          ),
                        ),
                      );
                    }),
                    if (hiddenItemCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppConstants.paddingSmall,
                        ),
                        child: Text(
                          'ほか $hiddenItemCount 件',
                          style: const TextStyle(
                            color: AppConstants.textColorGrey,
                            fontSize: AppConstants.fontSizeSmall,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
