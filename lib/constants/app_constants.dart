import 'package:flutter/material.dart';

class AppConstants {
  // --- 数値定数 ---
  static const double homeMemoCardWidth = 184.0;
  static const int homeMemoMaxPreviewItemCount = 7;
  static const double homeSearchBarHeight = 68.0;

  // --- サイズ・レイアウト定数 ---
  static const double gridCrossAxisSpacing = 10.0;
  static const double gridMainAxisSpacing = 10.0;
  static const double gridChildAspectRatio = 1.1;

  static const double paddingSmall = 4.0;
  static const double paddingMedium = 8.0;
  static const double paddingNormal = 12.0;
  static const double paddingLarge = 16.0;

  static const double borderRadiusSmall = 2.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 16.0;

  static const double iconSizeSmall = 18.0;
  static const double iconSizeMedium = 20.0;

  static const double fontSizeSmall = 14.0;
  static const double fontSizeNormal = 16.0;

  static const double cardElevation = 2.0;
  static const double sheetHandleWidth = 40.0;
  static const double sheetHandleHeight = 4.0;

  static const double bottomSheetMinSize = 0.3;
  static const double bottomSheetInitialSize = 0.6;
  static const double bottomSheetMaxSize = 0.95;

  static const int snackBarDurationSeconds = 1;

  // --- テキスト定数 ---
  static const String appTitle = '買い物メモ';
  static const String homeTitle = 'マイルーム（メモ一覧）';
  static const String textEmptyHome = 'メモ帳がありません。右下の＋から作成してください。';
  static const String textNoSearchResults = '一致するメモがありません';
  static const String labelPinnedMemos = 'ピン留め';
  static const String labelOtherMemos = 'その他';
  static const String textEmptyMemo = 'メモは空です';
  static const String textEmptyCompleted = 'アイテムはありません';

  static const String hintAddItem = 'アイテムを追加...';
  static const String hintMemoTitle = 'メモのタイトル';
  static const String hintNewMemoTitle = '新しいタイトル';
  static const String hintSearchMemos = 'タイトルや項目を検索';

  static const String labelAdd = '追加';
  static const String labelSelectAll = 'すべて選択';
  static const String labelBulkComplete = '一括完了（下へ送る）';
  static const String labelComplete = '完了';
  static const String labelRestoreToList = 'リストに戻す';
  static const String labelBulkRestore = '一括でリストに戻す';
  static const String labelClose = '閉じる';
  static const String labelClearSearch = '検索をクリア';
  static const String labelPinMemo = 'メモをピン留め';
  static const String labelUnpinMemo = 'ピン留めを解除';
  static const String labelCancel = 'キャンセル';
  static const String labelCreate = '作成';
  static const String labelSave = '保存';
  static const String labelRename = 'タイトル変更';
  static const String labelDelete = '削除';

  static const String dialogTitleNewMemo = '新しいメモ帳を作成';
  static const String dialogTitleRename = 'メモのタイトルを変更';
  static const String dialogTitleGlobalSettings = '全体設定（デフォルト）';
  static const String dialogTitleMemoSettings = 'このメモの設定';

  static const String settingFollowGlobalTitle = '全体のデフォルト設定に従う';
  static const String settingFollowGlobalSubtitle =
      'ONにするとホーム画面の全体設定が自動で反映されます';
  static const String settingStrikeThroughTitle = '完了済みに取り消し線を引く';
  static const String settingKeepCheckTitle = '移動時にチェック状態を維持する';
  static const String settingMoveUncheckedTitle = '未チェックも一括完了で移動する';

  static const String snackBarUncheckedWarning = 'チェックが入っていないため移動しません（設定で変更可能）';

  // --- 色・スタイリング定数 ---
  static const Color primarySeedColor = Colors.amber;
  static const Color homeBackgroundColor = Color(0xFFF3F3F3);
  static const Color editScreenBackgroundColor = Colors.white;
  static const Color memoCardColor = Colors.white;
  static const Color iconColorGrey = Colors.grey;
  static const Color textColorGrey = Colors.grey;
  static const Color textColorDark = Colors.black87;
  static const Color shadowColor = Colors.black;

  static final Color bottomSheetBgColor = Colors.grey[200]!;
  static final Color handleColor = Colors.grey[400]!;
}
