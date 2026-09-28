# memo_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 🏗 アーキテクチャ構成

本プロジェクトでは、保守性・テスト容易性・拡張性を高めるため、**MVVM（Model-View-ViewModel）パターン** を採用し、単一責任の原則（SRP）に基づいた設計を行っています。

lib/
 ├─ constants/
 │   └─ app_constants.dart      # アプリ共通の文言やサイズ等の定数
 ├─ models/
 │   ├─ memo_item.dart          # メモアイテムモデル[cite: 10]
 │   └─ memo_document.dart      # メモ帳・設定モデル[cite: 9]
 ├─ viewmodels/
 │   ├─ home_viewmodel.dart     # ホーム画面のロジック[cite: 11]
 │   └─ shopping_memo_viewmodel.dart # 詳細画面のロジック[cite: 12]
 └─ views/
     ├─ home_screen.dart        # ホーム画面[cite: 13]
     └─ shopping_memo/          # 買い物メモ関連の画面・部品をまとめる
         ├─ shopping_memo_home_page.dart # メイン画面
         ├─ components/
         │   ├─ completed_bottom_sheet.dart # ストック（完了済み）ボトムシート
         │   └─ memo_settings_dialog.dart     # 設定ダイアログ
         └─ widgets/
             └─ memo_item_tile.dart         # アイテム行の共通パーツ（任意）