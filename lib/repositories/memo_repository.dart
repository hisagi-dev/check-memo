import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/memo_document.dart';

class MemoRepository {
  final FirebaseFirestore _firestore;
  static const String _collectionName = 'memos';

  MemoRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // リアルタイムでメモ一覧の変更を監視・取得するStream
  Stream<List<MemoDocument>> getMemosStream() {
    return _firestore.collection(_collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return MemoDocument.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // メモ帳の新規追加
  Future addMemoDocument(MemoDocument memo) async {
    final docRef = _firestore.collection(_collectionName).doc();
    memo.id = docRef.id;
    await docRef.set(Map.from(memo.toMap()));
  }

  // メモ帳の更新（タイトル変更、アイテム追加・更新、設定変更等）
  Future updateMemoDocument(MemoDocument memo) async {
    await _firestore
        .collection(_collectionName)
        .doc(memo.id)
        .update(Map.from(memo.toMap()));
  }

  // メモ帳の削除
  Future deleteMemoDocument(String memoId) async {
    await _firestore.collection(_collectionName).doc(memoId).delete();
  }
}