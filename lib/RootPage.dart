import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shell/Service/Auth.dart';
import 'package:shell/Chat/ChatList.dart';
import 'package:shell/Service/UserModel.dart';
import 'package:shell/SignIn.dart';

class RootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<BaseAuth>(context);
    return StreamBuilder<User>(
      stream: auth.onAuthStateChanged,
      builder: (_, AsyncSnapshot<User> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User user = snapshot.data;
          if (user == null) {
            return SignIn();
          }
          // print("******************* User");
          return Provider<User>.value(
            value: user,
            child: ChatList(),
          );
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
