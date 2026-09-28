import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
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
                    onChanged: (value) {
                      setDialogState(() => strike = value);
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
                    onChanged: (value) {
                      setDialogState(() => keep = value);
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
                    onChanged: (value) {
                      setDialogState(() => move = value);
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
    late final MemoDocument memo;
    try {
      memo = await _viewModel.addMemoDocument(title);
    } on FirebaseException catch (error, stackTrace) {
      debugPrint(
        'Firebase memo creation failed: ${error.code}: ${error.message}',
      );
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Firebase保存エラー (${error.code}): ${error.message ?? '詳細不明'}',
          ),
          duration: const Duration(seconds: 8),
        ),
      );
      return;
    } catch (_) {
      debugPrint('Memo creation failed unexpectedly.');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('メモを保存できませんでした。デバッグログを確認してください。')),
      );
      return;
    }

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ShoppingMemoHomePage(
              memoDoc: memo,
              globalSettings: _viewModel.globalSettings,
            ),
      ),
    );
    if (mounted) setState(() {});
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
    final visibleMemos = _viewModel.filteredMemos;

    return Scaffold(
      backgroundColor: AppConstants.homeBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.homeBackgroundColor,
        title: const Text(AppConstants.homeTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(
            AppConstants.homeSearchBarHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.paddingNormal,
              0,
              AppConstants.paddingNormal,
              AppConstants.paddingSmall,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _viewModel.updateSearchQuery,
              decoration: InputDecoration(
                hintText: AppConstants.hintSearchMemos,
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _viewModel.searchQuery.isEmpty
                        ? null
                        : IconButton(
                          tooltip: AppConstants.labelClearSearch,
                          onPressed: () {
                            _searchController.clear();
                            _viewModel.updateSearchQuery('');
                          },
                          icon: const Icon(Icons.clear),
                        ),
                filled: true,
                fillColor: AppConstants.memoCardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppConstants.paddingSmall,
                ),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showGlobalSettingsDialog(context),
          ),
        ],
      ),
      body:
          _viewModel.loadError != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Text(
                    'Firestoreからメモを読み込めませんでした。\n\n'
                    '${_viewModel.loadError}\n\n'
                    'Firebase ConsoleでFirestore Databaseを作成し、'
                    'アプリと同じプロジェクトを選択してください。',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              : _viewModel.memos.isEmpty
              ? const Center(child: Text(AppConstants.textEmptyHome))
              : visibleMemos.isEmpty
              ? const Center(child: Text(AppConstants.textNoSearchResults))
              : LayoutBuilder(
                builder: (context, constraints) {
                  final pinnedMemos =
                      visibleMemos.where((memo) => memo.isPinned).toList();
                  final otherMemos =
                      visibleMemos.where((memo) => !memo.isPinned).toList();

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildMemoSection(
                          title: AppConstants.labelPinnedMemos,
                          memos: pinnedMemos,
                          availableWidth: constraints.maxWidth,
                        ),
                        _buildMemoSection(
                          title: AppConstants.labelOtherMemos,
                          memos: otherMemos,
                          availableWidth: constraints.maxWidth,
                        ),
                      ],
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMemoSection({
    required String title,
    required List<MemoDocument> memos,
    required double availableWidth,
  }) {
    if (memos.isEmpty) return const SizedBox.shrink();

    final cardWidth = AppConstants.homeMemoCardWidth;
    final spacing = AppConstants.gridCrossAxisSpacing;
    final horizontalPadding = AppConstants.paddingNormal * 2;
    final availableGridWidth = availableWidth - horizontalPadding;
    final columnCount = ((availableGridWidth + spacing) / (cardWidth + spacing))
        .floor()
        .clamp(1, memos.length);
    final gridWidth =
        columnCount * cardWidth +
        (columnCount - 1) * spacing +
        horizontalPadding;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.gridMainAxisSpacing),
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: gridWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.paddingNormal,
                  AppConstants.paddingNormal,
                  AppConstants.paddingNormal,
                  AppConstants.paddingSmall,
                ),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              MasonryGridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingNormal,
                ),
                crossAxisCount: columnCount,
                mainAxisSpacing: AppConstants.gridMainAxisSpacing,
                crossAxisSpacing: spacing,
                itemCount: memos.length,
                itemBuilder: (context, index) {
                  return _buildMemoCard(memos[index], cardWidth);
                },
              ),
            ],
          ),
        ),
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
        return LongPressDraggable<MemoDocument>(
          data: doc,
          feedback: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: cardWidth,
              child: Card(
                color: AppConstants.memoCardColor,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingNormal),
                  child: Text(
                    doc.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppConstants.fontSizeNormal,
                    ),
                  ),
                ),
              ),
            ),
          ),
          child: Card(
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
                      Text(
                        doc.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppConstants.fontSizeNormal,
                        ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (doc.isPinned)
                            const Padding(
                              padding: EdgeInsets.only(
                                right: AppConstants.paddingSmall,
                              ),
                              child: Tooltip(
                                message: AppConstants.labelUnpinMemo,
                                child: Icon(
                                  Icons.push_pin,
                                  size: AppConstants.iconSizeSmall,
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
                              } else if (value == 'pin' || value == 'unpin') {
                                _toggleMemoPin(doc);
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
                                  PopupMenuItem(
                                    value: doc.isPinned ? 'unpin' : 'pin',
                                    child: Text(
                                      doc.isPinned
                                          ? AppConstants.labelUnpinMemo
                                          : AppConstants.labelPinMemo,
                                    ),
                                  ),
                                ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleMemoPin(MemoDocument memo) async {
    try {
      await _viewModel.toggleMemoPin(memo);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ピン留めを保存できませんでした')));
    }
  }
}
