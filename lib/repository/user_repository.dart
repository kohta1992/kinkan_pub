import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kinkanutilapp/model/user_model.dart';

class UserRepository {
  static const collectionName = 'users';

  Future<void> update(UserModel user) async {
    FirebaseFirestore.instance
        .collection(collectionName)
        .doc(user.id)
        .update(user.firestoreData);
    return;
  }

  Future<void> updateState(User user, bool isWorking) async {
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(user.uid)
        .set(UserModel(
                id: user.uid, name: user.displayName, isWorking: isWorking)
            .firestoreData);
    return;
  }

  Future<void> add(UserModel user) async {
    FirebaseFirestore.instance
        .collection(collectionName)
        .doc()
        .set(user.firestoreData);
    return;
  }

  Future<void> delete(UserModel user) async {
    FirebaseFirestore.instance.collection(collectionName).doc(user.id).delete();
    return;
  }
}
