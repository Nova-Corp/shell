import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shell/Chat/ChatListModel.dart';
import 'package:shell/Conversation/ConversationView.dart';
import 'package:shell/Service/Auth.dart';

class NewChat extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewChat();
  }
}

class _NewChat extends State<NewChat> {
  final dbReference = FirebaseDatabase.instance.reference();
  Future<List<ChatUserModel>> _getUsers(BaseAuth auth) async {
    List<ChatUserModel> users = [];
    var usersNode = dbReference.child("users");
    await usersNode.once().then((DataSnapshot dataSnapshot) {
      var keys = dataSnapshot.value.keys;
      var data = dataSnapshot.value;
      auth.currentUser().then((cUser) {
        for (var individualKey in keys) {
          if (cUser == individualKey) {
            continue;
          }
          data[individualKey]["uid"] = individualKey;
          ChatUserModel chatUser = ChatUserModel(
              data[individualKey]["email"],
              data[individualKey]["name"],
              data[individualKey]["profileImage"],
              data[individualKey]["uid"],
              data[individualKey]["message"],
              data[individualKey]["timeStamp"]);
          users.add(chatUser);
        }
      });
    });
    return users;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<BaseAuth>(context);
    return MaterialApp(
      title: "New Chat",
      home: Scaffold(
        appBar: AppBar(
          title: Text("New Chat"),
          leading: IconButton(
              onPressed: () => _close(context), icon: Icon(Icons.close)),
        ),
        body: Container(
          child: FutureBuilder(
            future: _getUsers(auth),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _userListView(snapshot.data);
              } else if (snapshot.hasError) {
                return Text(snapshot.error);
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.blue[800]),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  ListView _userListView(List<ChatUserModel> users) {
    return ListView.separated(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(users[index].name),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(users[index].profileImage),
          ),
          subtitle: Text(users[index].email),
          trailing: Icon(
            Icons.notification_important,
            color: Colors.green,
          ),
          onTap: () => _gotoConversation(this.context, users[index]),
        );
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
    );
  }

  void _gotoConversation(context, ChatUserModel users) {
    _close(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ConversationView(user: users, context: context);
    }));
    // Navigator.of(context).popUntil((route) => route.isFirst);
    // Navigator.push(context, MaterialPageRoute(builder: (context) {
    //   return ConversationView();
    // }));
  }

  void _close(context) {
    Navigator.pop(context);
  }
}
