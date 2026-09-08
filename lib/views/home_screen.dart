import 'package:flutter/material.dart';
import '../viewmodels/home_viewmodel.dart';
import '../models/memo_document.dart';
import 'shopping_memo_home_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeViewModel _viewModel = HomeViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  // 全体設定ダイアログ
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
              title: const Text('全体設定（デフォルト）'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('完了済みに取り消し線を引く'),
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
                    title: const Text('移動時にチェック状態を維持する'),
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
                    title: const Text('未チェックも一括完了で移動する'),
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
                  child: const Text('閉じる'),
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
          title: const Text('新しいメモ帳を作成'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'メモのタイトル'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                _viewModel.addMemoDocument(controller.text);
                Navigator.pop(context);
              },
              child: const Text('作成'),
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
          title: const Text('メモのタイトルを変更'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: '新しいタイトル'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                _viewModel.renameMemoDocument(doc, controller.text);
                Navigator.pop(context);
              },
              child: const Text('保存'),
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
        title: const Text('マイルーム（メモ一覧）'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showGlobalSettingsDialog(context),
          ),
        ],
      ),
      body: _viewModel.memos.isEmpty
          ? const Center(child: Text('メモ帳がありません。右下の＋から作成してください。'))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.1,
              ),
              itemCount: _viewModel.memos.length,
              itemBuilder: (context, index) {
                final doc = _viewModel.memos[index];
                return Card(
                  elevation: 2,
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShoppingMemoHomePage(
                            memoDoc: doc,
                            homeViewModel: _viewModel, // 全体設定の参照を渡す
                          ),
                        ),
                      );
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
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
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, size: 18),
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
                                    child: Text('タイトル変更'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('削除'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(),
                          Expanded(
                            child: ListView(
                              physics: const NeverScrollableScrollPhysics(),
                              children: doc.items.take(3).map((item) {
                                return Text(
                                  '• ${item.text}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: item.isCompleted ? Colors.grey : Colors.black87,
                                    decoration: item.isChecked ? TextDecoration.lineThrough : null,
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