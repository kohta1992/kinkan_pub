import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kinkanutilapp/model/user_model.dart';
import 'package:kinkanutilapp/repository/user_repository.dart';
import 'package:kinkanutilapp/screen/user_item.dart';

class UsersPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final repository = UserRepository();

  List<UserModel> users = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var stream = FirebaseFirestore.instance
        .collection(UserRepository.collectionName)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        toolbarHeight: 40,
        elevation: 0,
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('勤務状況',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      body: Center(
        child: Stack(children: [
          Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: stream,
                  builder: (context, stream) {
                    if (stream.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (stream.hasError) {
                      return Center(child: Text(stream.error.toString()));
                    }

                    QuerySnapshot querySnapshot = stream.data;

                    return GridView.extent(
                        maxCrossAxisExtent: 250,
                        padding: const EdgeInsets.all(20),
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        children:
                            List.generate(querySnapshot.docs.length, (index) {
                          return UserItem(
                              user: UserModel.fromDocument(
                                  querySnapshot.docs[index]));
                        }));
                  },
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
