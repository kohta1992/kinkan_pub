import 'package:flutter/material.dart';
import 'package:kinkanutilapp/model/user_model.dart';


class UserItem extends StatelessWidget {
  final UserModel user;

  const UserItem({Key key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        color: Colors.white,
        border: Border.all(color:user.isWorking ? Colors.green: Colors.grey,width: 10),
        boxShadow: [
          BoxShadow(
            color: (user.isWorking ? Colors.green: Colors.grey).withOpacity(0.5),
            blurRadius: 3,
            offset: Offset(
              3.0, // horizontal, move right 10
              3.0, // vertical, move down 10
            ), // changes position of shadow
          ),
        ],
      ),
      child: InkWell(
        child: Padding(
          padding: EdgeInsets.all(0),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_circle_rounded,
                      color: Colors.black,
                      size: 100,
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "${user.name}",
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
