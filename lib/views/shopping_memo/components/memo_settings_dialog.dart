import 'package:flutter/material.dart';
import '../../../viewmodels/shopping_memo_viewmodel.dart';

class MemoSettingsDialog extends StatelessWidget {
  final ShoppingMemoViewModel viewModel;

  const MemoSettingsDialog({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setDialogState) {
        bool followGlobal = !viewModel.isCustomSettings;
        bool strike = viewModel.strikeThroughOnCompleted;
        bool keep = viewModel.keepCheckStateOnMove;
        bool move = viewModel.moveUncheckedOnComplete;

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
                    viewModel.setFollowGlobalSettings(value);
                    followGlobal = !viewModel.isCustomSettings;
                    strike = viewModel.strikeThroughOnCompleted;
                    keep = viewModel.keepCheckStateOnMove;
                    move = viewModel.moveUncheckedOnComplete;
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
                        viewModel.updateCustomSettingField(strikeThroughOnCompleted: val);
                      },
              ),
              SwitchListTile(
                title: const Text('移動時にチェック状態を維持する'),
                value: keep,
                onChanged: followGlobal
                    ? null
                    : (val) {
                        setDialogState(() => keep = val);
                        viewModel.updateCustomSettingField(keepCheckStateOnMove: val);
                      },
              ),
              SwitchListTile(
                title: const Text('未チェックも一括完了で移動する'),
                value: move,
                onChanged: followGlobal
                    ? null
                    : (val) {
                        setDialogState(() => move = val);
                        viewModel.updateCustomSettingField(moveUncheckedOnComplete: val);
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
  }
}