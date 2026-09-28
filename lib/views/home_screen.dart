import 'package:flutter/material.dart';
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
        return AlertDialog(
          title: const Text(AppConstants.dialogTitleNewMemo),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: AppConstants.hintMemoTitle),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppConstants.labelCancel),
            ),
            ElevatedButton(
              onPressed: () {
                _viewModel.addMemoDocument(controller.text);
                Navigator.pop(context);
              },
              child: const Text(AppConstants.labelCreate),
            ),
          ],
        );
      },
    );
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
            decoration: const InputDecoration(hintText: AppConstants.hintNewMemoTitle),
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
      appBar: AppBar(
        title: const Text(AppConstants.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showGlobalSettingsDialog(context),
          ),
        ],
      ),
      body: _viewModel.memos.isEmpty
          ? const Center(child: Text(AppConstants.textEmptyHome))
          : GridView.builder(
              padding: const EdgeInsets.all(AppConstants.paddingNormal),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppConstants.gridCrossAxisSpacing,
                mainAxisSpacing: AppConstants.gridMainAxisSpacing,
                childAspectRatio: AppConstants.gridChildAspectRatio,
              ),
              itemCount: _viewModel.memos.length,
              itemBuilder: (context, index) {
                final doc = _viewModel.memos[index];
                return Card(
                  elevation: AppConstants.cardElevation,
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShoppingMemoHomePage(
                            memoDoc: doc,
                            globalSettings: _viewModel.globalSettings,
                          ),
                        ),
                      );
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingNormal),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              PopupMenuButton(
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
                                itemBuilder: (context) => [
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
                          Expanded(
                            child: ListView(
                              physics: const NeverScrollableScrollPhysics(),
                              // map に  を明示して List に変換されるように修正
                              children: doc.items
                                  .take(AppConstants.homePreviewItemCount)
                                  .map<Widget>((item) {
                                return Text(
                                  '• ${item.text}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: item.isCompleted
                                        ? AppConstants.textColorGrey
                                        : AppConstants.textColorDark,
                                    decoration: item.isChecked
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
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
}