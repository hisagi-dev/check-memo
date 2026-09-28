import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
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
          title: const Text(AppConstants.dialogTitleMemoSettings),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text(AppConstants.settingFollowGlobalTitle),
                subtitle: const Text(AppConstants.settingFollowGlobalSubtitle),
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
                title: const Text(AppConstants.settingStrikeThroughTitle),
                value: strike,
                onChanged: followGlobal
                    ? null
                    : (val) {
                        setDialogState(() => strike = val);
                        viewModel.updateCustomSettingField(strikeThroughOnCompleted: val);
                      },
              ),
              SwitchListTile(
                title: const Text(AppConstants.settingKeepCheckTitle),
                value: keep,
                onChanged: followGlobal
                    ? null
                    : (val) {
                        setDialogState(() => keep = val);
                        viewModel.updateCustomSettingField(keepCheckStateOnMove: val);
                      },
              ),
              SwitchListTile(
                title: const Text(AppConstants.settingMoveUncheckedTitle),
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
              child: const Text(AppConstants.labelClose),
            ),
          ],
        );
      },
    );
  }
}