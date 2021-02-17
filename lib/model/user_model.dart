import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String id;
  String name;
  bool isWorking;

  UserModel({this.id, this.name, this.isWorking});

  ///
  ///FireStoreへセットする用の形式で取得
  ///
  Map<String, dynamic> get firestoreData => {
        'user_name': name,
        'is_working': isWorking,
      };

  ///
  /// ドキュメントのスナップショットからインスタンスを生成
  ///
  factory UserModel.fromDocument(DocumentSnapshot document) => UserModel(
        id: document.id,
        name: document.data()['user_name'],
        isWorking: document.data()['is_working'],
      );
}
